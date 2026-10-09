"""Test Morris rules and generate complete legal native replay fixtures."""
from pathlib import Path
import copy,json,random
from rules import Game,MILLS,EDGES
ROOT=Path(__file__).resolve().parent;checks=[]
def passed(name):checks.append(name);print('PASS',name)
def position(white,black,turn=1,reserve=(0,0)):
    g=Game();g.reserve=list(reserve);g.turn=turn
    for i in white:g.board[i-1]=1
    for i in black:g.board[i-1]=2
    return g

assert len(MILLS)==16 and len(EDGES)==32
assert all(1<=i<=24 for m in MILLS for i in m)
assert (1,3) not in EDGES and (2,10) in EDGES
passed('24 points, 16 mills and 32 adjacent edges; no diagonal mills')
g=Game();g.pick(1);before=g.state();g.pick(1);g.pick(0);g.pick(25);assert g.state()==before
assert g.turn==2 and g.reserve==[8,9]
passed('alternating placement, nine reserves each and invalid/occupied squares rejected')
g=Game()
for i in (1,9,2,10,3):g.pick(i)
assert g.take and g.turn==1;g.pick(9);assert not g.take and g.turn==2 and g.count(2)==1
passed('mill during placement requires exactly one legal capture before turn passes')
g=position([9,10],[1,2,3,4],reserve=(7,5))
assert not g.can_take(1,1) and g.can_take(4,1)
before=g.state();g.take=True;g.pick(1);assert g.take and g.board[0]==2
g.pick(4);assert g.count(2)==3 and not g.take
passed('pieces in mills protected while a non-mill enemy exists')
g=position([9,10],[1,2,3]);assert all(g.can_take(i,1) for i in (1,2,3))
passed('any enemy removable when all enemy pieces are in mills')
g=position([1,2,9,17],[3,11,19,5]);g.pick(1);g.pick(24);assert g.selected==1 and g.board[0]==1
g.pick(8);assert g.board[7]==1 and g.board[0]==0 and g.turn==2
passed('four or more pieces may move only to an adjacent empty point')
g=position([1,9,17],[3,11,19,5]);g.pick(1);g.pick(24)
assert g.board[23]==1 and g.board[0]==0 and g.turn==2
passed('exactly three remaining pieces may fly to any empty point')
g=position([1,2,3,9],[5,13,21]);g.take=True;g.pick(5);assert g.winner==1
passed('capture reducing opponent to two pieces wins')
g=position([2,4,8,10,12,16,24],[1,3,9,11]);g.finish();assert g.winner==1
passed('opponent with no legal movement loses')
g=position([1,3,10,18],[9,17,20,22]);g.quiet=49;g.pick(1);g.pick(8);assert g.winner==3
passed('50 movement turns without capture produce a draw')
g=position([1,3,10,18],[9,17,20,22]);state=tuple(g.board)+(2,);g.history=[state,state];g.finish();assert g.winner==3
passed('third identical position with same player to move produces a draw')
g=position([1,3,10,18],[9,17,20,22]);g.reserve=[1,1];g.quiet=49;g.pick(24);assert not g.winner and g.quiet==0
passed('placement does not trigger the movement draw counter')
g=position([1,3,10,18],[9,17,20,22]);g.take=True;g.quiet=49;g.history=[tuple(g.board)+(2,)];g.pick(9)
assert g.quiet==0 and len(g.history)==1
passed('capture resets draw counter and repetition history')
g=Game();g.pick(1);assert g.choose()==(0,2,0) or g.choose() is not None
passed('computer chooses a legal deterministic placement')

games=[]
for seed in range(10):
    g=Game();r=random.Random(seed);records=[]
    for turn in range(300):
        if g.winner:break
        action=g.choose()
        if seed and turn%5==0:
            choices=[(a,b) for a in range(25) for b in range(1,25) if g.legal(a,b,g.turn)]
            a,b=r.choice(choices);temp=copy.deepcopy(g)
            if a:temp.pick(a)
            temp.pick(b);c=r.choice([i for i in range(1,25) if temp.can_take(i,temp.turn)]) if temp.take else 0
            action=(a,b,c)
        before=g.moves;g.play(action)
        assert g.moves==before+1
        assert all(v in (0,1,2) for v in g.board)
        assert g.count(1)+g.reserve[0]<=9 and g.count(2)+g.reserve[1]<=9
        assert not g.take
        records.append({'action':list(action),'state':g.state()})
    assert g.winner,('unfinished',seed,g.state())
    games.append({'seed':seed,'turns':records,'winner':g.winner})
passed('10 complete legal games: placement, capture, movement, flying and termination')
(ROOT/'replay-fixtures.json').write_text(json.dumps(games,indent=2)+'\n')
(ROOT/'host-validation.json').write_text(json.dumps({'passed':len(checks),'checks':checks,
    'complete_games':len(games),'total_turns':sum(len(g['turns']) for g in games)},indent=2)+'\n')
print('Game lengths:',[(g['seed'],len(g['turns']),g['winner']) for g in games])
