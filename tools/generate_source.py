"""Build the native Malom program from the tested Lisa LOS shell."""
from pathlib import Path
import shutil,json
ROOT=Path(__file__).resolve().parent
MILLS=[(1,2,3),(3,4,5),(5,6,7),(7,8,1),
       (9,10,11),(11,12,13),(13,14,15),(15,16,9),
       (17,18,19),(19,20,21),(21,22,23),(23,24,17),
       (2,10,18),(4,12,20),(6,14,22),(8,16,24)]
XY=[]
for left,right,top,bottom in ((24,240,40,216),(60,204,69,187),(96,168,98,158)):
    XY.extend(((left,top),(132,top),(right,top),(right,128),
               (right,bottom),(132,bottom),(left,bottom),(left,128)))
source=(ROOT/'templates/KigyoM.TEXT').read_text().replace('program Kigyo;', 'program Malom;')
a=source.index('   snWidth =');b=source.index('   nextClkPoll :')
source=source[:a]+'''type BOVideoPtr = ^integer;
var
   mmFlags, mmBoard, mmShown, mmX, mmY : array[1..24] of integer;
   mmLines : array[1..48] of integer;
   mmHistory : array[1..101,1..25] of integer;
   mmNext : longint;
   mmHudShown : array[1..11] of Str255;
'''+source[b:]
init='procedure MMInit;\nbegin\n'
for i,(x,y) in enumerate(XY,1):init+=f'   mmX[{i}] := {x}; mmY[{i}] := {y};\n'
for i,value in enumerate(sum((list(m) for m in MILLS),[]),1):init+=f'   mmLines[{i}] := {value};\n'
init+='end;\n'
a=source.index('function SNDelay');b=source.index('procedure doUpdateEvent')
source=source[:a]+init+(ROOT.parent/'src/game.pas').read_text()+source[b:]
source=source.replace('snPaint := false;', 'mmFlags[17] := 0;').replace('SNDraw', 'MMDraw')
source=source.replace('if not snReady then SNNew;', 'if mmFlags[16]=0 then MMNew;')
source=source.replace('SNKey(theEvent.ascii)', 'MMKey(theEvent.ascii)')
source=source.replace('else if theEvent.who = myWindow then\n;', 'else if theEvent.who = myWindow then\nMMClick;')
source=source.replace('snPause := true; snHud := true; MMDraw;', 'mmFlags[6] := 0; MMDirty;')
source=source.replace('TakeControl(theEvent, false, false);', 'TakeControl(theEvent, false, false);\nif theEvent.who=myWindow then MMDraw;')
source=source.replace('snReady := false; snSpeed := 1; snWalls := true;', 'MMInit; mmFlags[16] := 0; mmFlags[2] := 1;')
source=source.replace('SNTick;', 'MMTick;')
assert 'snReady' not in source and 'SNDraw' not in source and 'snPaint' not in source
(ROOT.parent/'src/M.TEXT').write_bytes(source.replace('\n','\r').encode('ascii'))
(ROOT.parent/'src/board.json').write_text(json.dumps({'mills':MILLS,'coordinates':XY},indent=2)+'\n')
print('Malom source',len(source),'bytes')
