"""Independent reference model for release tests and native replay fixtures."""
from pathlib import Path
import json
MILLS=[tuple(x) for x in json.loads((Path(__file__).parent.parent/'src/board.json').read_text())['mills']]
EDGES={tuple(sorted(pair)) for m in MILLS for pair in zip(m,m[1:])}

class Game:
    def __init__(self):
        self.board=[0]*24;self.reserve=[9,9];self.turn=1
        self.selected=0;self.take=False;self.winner=0;self.quiet=0
        self.moves=0;self.history=[];self.last=(0,0,0)
    def count(self,p):return self.board.count(p)
    def mill(self,cell,p):
        return any(cell in m and all(self.board[i-1]==p for i in m) for m in MILLS)
    def can_take(self,cell,p):
        if not 1<=cell<=24 or self.board[cell-1]!=3-p:return False
        outside=any(v==3-p and not self.mill(i,3-p) for i,v in enumerate(self.board,1))
        return not outside or not self.mill(cell,3-p)
    def legal(self,a,b,p):
        if not 1<=b<=24 or self.board[b-1]:return False
        if sum(self.reserve):return a==0 and self.reserve[p-1]>0
        return 1<=a<=24 and self.board[a-1]==p and (self.count(p)==3 or tuple(sorted((a,b))) in EDGES)
    def has_move(self,p):
        return any(self.legal(a,b,p) for a in range(25) for b in range(1,25))
    def finish(self):
        self.selected=0;self.take=False;self.moves+=1;self.turn=3-self.turn
        if self.count(self.turn)+self.reserve[self.turn-1]<3 or not self.has_move(self.turn):
            self.winner=3-self.turn
        if not self.winner and not sum(self.reserve):
            state=tuple(self.board)+(self.turn,)
            if self.history.count(state)>=2:self.winner=3
            if len(self.history)<101:self.history.append(state)
            if self.quiet>=50:self.winner=3
    def pick(self,cell):
        if not 1<=cell<=24 or self.winner:return
        p=self.turn
        if self.take:
            if self.can_take(cell,p):
                self.board[cell-1]=0;self.quiet=0;self.history=[]
                self.last=self.last[:2]+(cell,);self.finish()
            return
        a=0
        if not sum(self.reserve):
            if self.board[cell-1]==p:self.selected=cell;return
            a=self.selected
            if not a:return
        if not self.legal(a,cell,p):return
        self.last=(a,cell,0)
        if not a:self.reserve[p-1]-=1;self.quiet=0
        else:self.board[a-1]=0;self.quiet+=1
        self.board[cell-1]=p;self.selected=0
        if self.mill(cell,p) and self.count(3-p):self.take=True
        else:self.finish()
    def score(self,p):
        q=3-p;c1=self.count(p);c2=self.count(q)
        if c2+self.reserve[q-1]<3:return 10000
        if c1+self.reserve[p-1]<3:return -10000
        m1=m2=p1=p2=0
        for mill in MILLS:
            values=[self.board[i-1] for i in mill]
            own=values.count(p);other=values.count(q)
            m1+=own==3;m2+=other==3;p1+=own==2 and other==0;p2+=other==2 and own==0
        def mobility(player):
            return sum(self.board[a-1]==player and self.board[b-1]==0
                       for a,b in [pair for e in EDGES for pair in (e,e[::-1])])
        mob1=mobility(p);mob2=mobility(q)
        if not sum(self.reserve):
            if mob2==0 and c2>3:return 10000
            if mob1==0 and c1>3:return -10000
        return (c1+self.reserve[p-1]-c2-self.reserve[q-1])*120+(m1-m2)*35+p1*16-p2*28+(mob1-mob2)*2
    def choose(self,p=None):
        p=p or self.turn;best=-30000;action=None
        if self.take:
            for c in range(1,25):
                if self.can_take(c,p):
                    self.board[c-1]=0;s=self.score(p);self.board[c-1]=3-p
                    if s>best:best=s;action=(0,0,c)
            return action
        original=self.board.copy();reserve=self.reserve.copy()
        for a in range(25):
            for b in range(1,25):
                if not self.legal(a,b,p):continue
                if not a:self.reserve[p-1]-=1
                else:self.board[a-1]=0
                self.board[b-1]=p
                if self.mill(b,p) and self.count(3-p):
                    for c in range(1,25):
                        if self.can_take(c,p):
                            self.board[c-1]=0;s=self.score(p);self.board[c-1]=3-p
                            if s>best:best=s;action=(a,b,c)
                else:
                    s=self.score(p)
                    if s>best:best=s;action=(a,b,0)
                self.board=original.copy();self.reserve=reserve.copy()
        return action
    def play(self,action):
        a,b,c=action
        if a:self.pick(a)
        if b:self.pick(b)
        if c:self.pick(c)
    def state(self):
        return {'board':self.board.copy(),'reserve':self.reserve.copy(),
                'counts':[self.count(1),self.count(2)],'turn':self.turn,
                'selected':self.selected,'capture':self.take,'winner':self.winner,
                'quiet':self.quiet,'moves':self.moves,'last':list(self.last)}
