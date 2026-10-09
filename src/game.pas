function MMAdj(a,b : integer) : boolean;
var i,p : integer;
begin
   MMAdj := false;
   for i := 0 to 15 do begin
      p := i*3+1;
      if ((mmLines[p]=a) and (mmLines[p+1]=b)) or
         ((mmLines[p+1]=a) and (mmLines[p]=b)) or
         ((mmLines[p+1]=a) and (mmLines[p+2]=b)) or
         ((mmLines[p+2]=a) and (mmLines[p+1]=b)) then
         MMAdj := true
   end
end;
function MMMill(cell,player : integer) : boolean;
var i,p : integer;
begin
   MMMill := false;
   for i := 0 to 15 do begin
      p := i*3+1;
      if (mmLines[p]=cell) or (mmLines[p+1]=cell) or (mmLines[p+2]=cell) then
      if (mmBoard[mmLines[p]]=player) and
         (mmBoard[mmLines[p+1]]=player) and
         (mmBoard[mmLines[p+2]]=player) then MMMill := true
   end
end;
function MMCanTake(cell,player : integer) : boolean;
var i : integer;
    outside : boolean;
begin
   MMCanTake := false;
   if (cell<1) or (cell>24) then exit(MMCanTake);
   if mmBoard[cell]<>3-player then exit(MMCanTake);
   outside := false;
   for i := 1 to 24 do
      if mmBoard[i]=3-player then
         if not MMMill(i,3-player) then outside := true;
   MMCanTake := (not outside) or (not MMMill(cell,3-player))
end;
function MMLegal(a,b,player : integer) : boolean;
begin
   MMLegal := false;
   if (b<1) or (b>24) then exit(MMLegal);
   if mmBoard[b]<>0 then exit(MMLegal);
   if (mmFlags[9]+mmFlags[10])>0 then begin
      MMLegal := (a=0) and (mmFlags[8+player]>0);
      exit(MMLegal)
   end;
   if (a<1) or (a>24) then exit(MMLegal);
   if mmBoard[a]<>player then exit(MMLegal);
   MMLegal := (mmFlags[10+player]=3) or MMAdj(a,b)
end;
function MMHasMove(player : integer) : boolean;
var a,b : integer;
begin
   MMHasMove := false;
   for a := 0 to 24 do
      for b := 1 to 24 do
         if MMLegal(a,b,player) then begin
            MMHasMove := true; exit(MMHasMove)
         end
end;
procedure MMDirty;
begin
   mmFlags[18] := 1
end;
procedure MMRecordHistory;
var i,j,same : integer;
    equal : boolean;
begin
   if (mmFlags[9]+mmFlags[10])<>0 then exit(MMRecordHistory);
   same := 0;
   for i := 1 to mmFlags[13] do begin
      equal := true;
      for j := 1 to 24 do
         if mmHistory[i,j]<>mmBoard[j] then equal := false;
      if equal then
         if mmHistory[i,25]=mmFlags[1] then same := same+1
   end;
   if same>=2 then mmFlags[5] := 3;
   if mmFlags[13]<101 then begin
      mmFlags[13] := mmFlags[13]+1;
      for j := 1 to 24 do mmHistory[mmFlags[13],j] := mmBoard[j];
      mmHistory[mmFlags[13],25] := mmFlags[1]
   end;
   if mmFlags[7]>=50 then mmFlags[5] := 3
end;
procedure MMFinish;
var other : integer;
begin
   other := 3-mmFlags[1];
   mmFlags[3] := 0; mmFlags[4] := 0;
   mmFlags[8] := mmFlags[8]+1;
   mmFlags[1] := other;
   if (mmFlags[10+other]+mmFlags[8+other])<3 then
      mmFlags[5] := 3-other
   else if not MMHasMove(other) then mmFlags[5] := 3-other;
   if mmFlags[5]=0 then MMRecordHistory;
   mmNext := Time+20;
   MMDirty
end;
procedure MMText(row,y : integer; text : Str255);
var box : Rect;
begin
   if (mmFlags[17]=0) or (mmHudShown[row]<>text) then begin
      SetRect(box,270,y-12,499,y+3); EraseRect(box);
      MoveTo(270,y); DrawString(text); mmHudShown[row] := text
   end
end;
procedure MMDraw;
var i,j,x,y,value,offset : integer;
    box : Rect;
    s : Str255;
begin
   if myWindow=nil then exit(MMDraw);
   SetPort(myWindow); ClipRect(myWindow^.portRect); PenSize(1,1);
   if mmFlags[17]=0 then begin
      EraseRect(myWindow^.portRect);
      MoveTo(16,18); DrawString('MALOM');
      for i := 0 to 15 do begin
         j := i*3+1;
         MoveTo(mmX[mmLines[j]],mmY[mmLines[j]]);
         LineTo(mmX[mmLines[j+2]],mmY[mmLines[j+2]])
      end;
      for i := 1 to 24 do begin
         NumToStr(i,s); MoveTo(mmX[i]+8,mmY[i]-6); DrawString(s)
      end;
      MoveTo(16,247); DrawString('EGY MALOM = EGY ELLENFEL KORONG LEVETELE');
      mmFlags[18] := 1
   end;
   for i := 1 to 24 do begin
      value := mmBoard[i];
      if mmFlags[3]=i then value := value+4;
      if mmFlags[4]=1 then
         if MMCanTake(i,mmFlags[1]) then value := value+8;
      if (mmFlags[17]=0) or (mmShown[i]<>value) then begin
         x := mmX[i]; y := mmY[i];
         SetRect(box,x-9,y-7,x+10,y+8); EraseRect(box);
         for j := 1 to 24 do if MMAdj(i,j) then begin
            MoveTo(x,y);
            if mmX[j]>x then LineTo(x+9,y)
            else if mmX[j]<x then LineTo(x-9,y)
            else if mmY[j]>y then LineTo(x,y+7)
            else LineTo(x,y-7)
         end;
         SetRect(box,x-6,y-4,x+7,y+5); EraseOval(box);
         if mmBoard[i]=0 then begin
            SetRect(box,x-1,y-1,x+2,y+2); PaintRect(box)
         end
         else if mmBoard[i]=1 then FrameOval(box)
         else PaintOval(box);
         if value>=4 then begin
            SetRect(box,x-9,y-7,x+10,y+8); FrameOval(box)
         end;
         mmShown[i] := value
      end
   end;
   if mmFlags[18]<>0 then begin
      if mmFlags[2]=1 then s := 'EMBER (O) - GEP (FEKETE)'
      else s := 'KET JATEKOS';
      MMText(1,40,s);
      if mmFlags[5]=1 then s := 'A VILAGOS NYERT!'
      else if mmFlags[5]=2 then s := 'A FEKETE NYERT!'
      else if mmFlags[5]=3 then s := 'DONTETLEN!'
      else if mmFlags[1]=1 then s := 'VILAGOS KOVETKEZIK'
      else s := 'FEKETE KOVETKEZIK';
      MMText(2,60,s);
      if mmFlags[5]<>0 then s := 'N: UJ JATEK'
      else if (mmFlags[2]=1) and (mmFlags[1]=2) then s := 'GEP GONDOLKODIK...'
      else if mmFlags[4]=1 then s := 'VALASSZ LEVEENDO KORONGOT'
      else if mmFlags[9]+mmFlags[10]>0 then s := 'RAKJ LE EGY KORONGOT'
      else if mmFlags[3]=0 then s := 'VALASSZ SAJAT KORONGOT'
      else if mmFlags[10+mmFlags[1]]=3 then s := 'UGORJ BARMELY URES MEZORE'
      else s := 'LEPJ SZOMSZEDOS MEZORE';
      MMText(3,80,s);
      NumToStr(mmFlags[9],s); MMText(4,105,concat('LERAKHATO O: ',s));
      NumToStr(mmFlags[10],s); MMText(5,120,concat('LERAKHATO FEKETE: ',s));
      NumToStr(mmFlags[11],s); MMText(6,140,concat('TABLAN O: ',s));
      NumToStr(mmFlags[12],s); MMText(7,155,concat('TABLAN FEKETE: ',s));
      MMText(8,179,'KATTINTS VAGY 1-24 + ENTER');
      NumToStr(mmFlags[6],s); MMText(9,194,concat('BEIRT MEZO: ',s));
      MMText(10,214,'G: GEP   K: KET JATEKOS');
      MMText(11,229,'N: UJ   ESC: KIJEL. TORLES');
      mmFlags[18] := 0
   end;
   mmFlags[17] := 1
end;
procedure MMNew;
var i : integer;
begin
   for i := 1 to 24 do begin mmBoard[i] := 0; mmShown[i] := -1 end;
   for i := 1 to 24 do if i<>2 then mmFlags[i] := 0;
   mmFlags[1] := 1; mmFlags[9] := 9; mmFlags[10] := 9;
   mmFlags[15] := 19789; mmFlags[16] := 1;
   mmFlags[17] := 0;
   mmNext := Time+20; MMDirty; MMDraw
end;
procedure MMPick(cell : integer);
var a,player : integer;
begin
   if (cell<1) or (cell>24) or (mmFlags[5]<>0) then exit(MMPick);
   player := mmFlags[1];
   if mmFlags[4]=1 then begin
      if MMCanTake(cell,player) then begin
         mmBoard[cell] := 0;
         mmFlags[10+3-player] := mmFlags[10+3-player]-1;
         mmFlags[21] := cell; mmFlags[7] := 0; mmFlags[13] := 0;
         MMFinish
      end
   end
   else begin
      a := 0;
      if mmFlags[9]+mmFlags[10]=0 then begin
         if mmBoard[cell]=player then begin
            mmFlags[3] := cell; MMDirty; MMDraw; exit(MMPick)
         end;
         a := mmFlags[3];
         if a=0 then exit(MMPick)
      end;
      if MMLegal(a,cell,player) then begin
         mmFlags[19] := a; mmFlags[20] := cell; mmFlags[21] := 0;
         if a=0 then begin
            mmFlags[8+player] := mmFlags[8+player]-1;
            mmFlags[10+player] := mmFlags[10+player]+1;
            mmFlags[7] := 0
         end
         else begin mmBoard[a] := 0; mmFlags[7] := mmFlags[7]+1 end;
         mmBoard[cell] := player; mmFlags[3] := 0;
         if MMMill(cell,player) and (mmFlags[10+3-player]>0) then begin
            mmFlags[4] := 1; MMDirty
         end
         else MMFinish
      end
   end;
   MMDraw
end;
function MMScore : integer;
var i,j,p,n1,n2,m1,m2,p1,p2,mob1,mob2,value : integer;
begin
   if mmFlags[11]+mmFlags[9]<3 then begin MMScore := 10000; exit(MMScore) end;
   if mmFlags[12]+mmFlags[10]<3 then begin MMScore := -10000; exit(MMScore) end;
   m1 := 0; m2 := 0; p1 := 0; p2 := 0;
   for i := 0 to 15 do begin
      p := i*3+1; n1 := 0; n2 := 0;
      for j := 0 to 2 do begin
         value := mmBoard[mmLines[p+j]];
         if value=1 then n1 := n1+1;
         if value=2 then n2 := n2+1
      end;
      if n1=3 then m1 := m1+1;
      if n2=3 then m2 := m2+1;
      if (n1=2) and (n2=0) then p1 := p1+1;
      if (n2=2) and (n1=0) then p2 := p2+1
   end;
   mob1 := 0; mob2 := 0;
   for i := 1 to 24 do if mmBoard[i]<>0 then
      for j := 1 to 24 do if mmBoard[j]=0 then
         if MMAdj(i,j) then begin
            if mmBoard[i]=1 then mob1 := mob1+1 else mob2 := mob2+1
         end;
   if (mmFlags[9]+mmFlags[10])=0 then begin
      if (mob1=0) and (mmFlags[11]>3) then begin MMScore := 10000; exit(MMScore) end;
      if (mob2=0) and (mmFlags[12]>3) then begin MMScore := -10000; exit(MMScore) end
   end;
   MMScore := (mmFlags[12]+mmFlags[10]-mmFlags[11]-mmFlags[9])*120+
      (m2-m1)*35+p2*16-p1*28+(mob2-mob1)*2
end;
procedure MMAI;
var a,b,c,score,best,ba,bb,bc,oldReserve,oldCount,oldEnemy,trials : integer;
begin
   best := -30000; ba := 0; bb := 0; bc := 0; trials := 0;
   if mmFlags[4]=1 then begin
      for c := 1 to 24 do if MMCanTake(c,2) then begin
         mmBoard[c] := 0; mmFlags[11] := mmFlags[11]-1;
         score := MMScore;
         mmFlags[11] := mmFlags[11]+1; mmBoard[c] := 1;
         if score>best then begin best := score; bc := c end
      end;
      if bc<>0 then MMPick(bc);
      exit(MMAI)
   end;
   oldReserve := mmFlags[10]; oldCount := mmFlags[12]; oldEnemy := mmFlags[11];
   for a := 0 to 24 do for b := 1 to 24 do
      if MMLegal(a,b,2) then begin
         if a=0 then begin mmFlags[10] := oldReserve-1; mmFlags[12] := oldCount+1 end
         else mmBoard[a] := 0;
         mmBoard[b] := 2;
         if MMMill(b,2) and (oldEnemy>0) then begin
            for c := 1 to 24 do if MMCanTake(c,2) then begin
               mmBoard[c] := 0; mmFlags[11] := oldEnemy-1;
               score := MMScore;
               mmFlags[11] := oldEnemy; mmBoard[c] := 1;
               if score>best then begin best := score; ba := a; bb := b; bc := c end
            end
         end
         else begin
            score := MMScore;
            if score>best then begin best := score; ba := a; bb := b; bc := 0 end
         end;
         mmBoard[b] := 0; if a<>0 then mmBoard[a] := 2;
         mmFlags[10] := oldReserve; mmFlags[12] := oldCount;
         trials := trials+1;
         if (trials mod 8)=0 then LetOthersRun
      end;
   if bb=0 then begin mmFlags[5] := 1; MMDirty; MMDraw end
   else begin
      mmFlags[14] := mmFlags[14]+1;
      if ba<>0 then MMPick(ba);
      MMPick(bb);
      if (mmFlags[4]=1) and (bc<>0) then MMPick(bc)
   end
end;
procedure MMTick;
begin
   if (myWindow=nil) or (activeFolder<>myWindow) then exit(MMTick);
   if (mmFlags[16]=0) or (mmFlags[5]<>0) then exit(MMTick);
   if (mmFlags[2]=1) and (mmFlags[1]=2) and (Time>=mmNext) then MMAI
end;
procedure MMKey(ch : char);
var cell : integer;
begin
   if ch='g' then begin mmFlags[2] := 1; MMNew end
   else if ch='G' then begin mmFlags[2] := 1; MMNew end
   else if (ch='k') or (ch='K') then begin mmFlags[2] := 2; MMNew end
   else if (ch='n') or (ch='N') then MMNew
   else if (ord(ch)=27) or (ord(ch)=8) then begin
      mmFlags[3] := 0; mmFlags[6] := 0; MMDirty; MMDraw
   end
   else if (mmFlags[2]=1) and (mmFlags[1]=2) then exit(MMKey)
   else if (ch>='0') and (ch<='9') then begin
      cell := mmFlags[6]*10+ord(ch)-ord('0');
      if cell>24 then cell := ord(ch)-ord('0');
      mmFlags[6] := cell; mmFlags[18] := 1; MMDraw
   end
   else if ord(ch)=13 then begin
      cell := mmFlags[6]; mmFlags[6] := 0; mmFlags[18] := 1;
      MMPick(cell); MMDraw
   end
end;
procedure MMClick;
var pt : Point;
    i : integer;
begin
   if (mmFlags[2]=1) and (mmFlags[1]=2) then exit(MMClick);
   SetPort(myWindow); GetMouse(pt);
   for i := 1 to 24 do
      if (abs(pt.h-mmX[i])<=12) and (abs(pt.v-mmY[i])<=9) then begin
         mmFlags[6] := 0; MMDirty; MMPick(i); MMDraw; exit(MMClick)
      end
end;
