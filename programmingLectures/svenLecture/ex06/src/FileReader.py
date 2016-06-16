import re
import os
import sys

def correctLineLength(map):
    """
    search longest line and fill up with whitespaces
    """
    maxLength=0
    for row in map:
        maxLength=max(maxLength,len(row))
    
    for i in range(len(map)):
        row = map[i]
        if len(row) < maxLength:
            map[i] = row + [' ']*(maxLength-len(row))
            
    return map

def readMap(fileName):
    lines=[]
    for l in open(fileName):
        l=l.rstrip('\n')
        match = re.search('([a-zA-Z\~\^\s\$]+)', l)
        if(match):
            line = match.group(1)
            lines.append(list(line))
    lines = correctLineLength(lines)
    return lines


class BoardInfo(object):
    # c == after all coins are collected; d == after one player has 10 coins (infinite coins)
    StopCriterion = None
    MaximalCoins = None
    RemainingCoins = None
    PlayerCoins = {}
    PlayerPositions = {}
    PlayerList = []
    Map = None
        
def readBoard(fileName):
    myBoard = BoardInfo()
    d={}
    key=""
    with open(fileName) as f:
        for line in iter(f):
            #print "reading line ",line
            if line.startswith("board:"):
                emptyList = []
                key="board"
                d.update({key:emptyList})
                continue
            if line.startswith("configs:"):
                emptyList = []
                key="configs"
                d.update({key:emptyList})
                continue
            if line.startswith("board data:"):
                emptyList = []
                key ="board data"
                d.update({key:emptyList})
                continue
            if line.startswith("player coins:"):
                emptyList = []
                key ="player coins"
                d.update({key:emptyList})
                continue
            if(key): # key is not empty
                d[key].append(line)
        f.close()
   
    for i,line in enumerate(d["board"]):
        line = line.rstrip('\n')
        line = list(line)
        d["board"][i] = line
        
    correctLineLength(d["board"])
    myBoard.Map = d["board"]
    
    for line in d["player coins"]:
        line = line.rstrip('\n')
        nameAndCoins = line.split(':')
        if len(nameAndCoins) == 2:
            name = nameAndCoins[0]
            playerCoins = nameAndCoins[1]
            myBoard.PlayerList.append(name)
            myBoard.PlayerCoins[name] = playerCoins
    
    configs = d["configs"] + d["board data"]
    for line in configs:
        line = line.rstrip('\n')
        nameAndValue = line.split(':')
        name = nameAndValue[0]
        value = nameAndValue[1]
        if name.startswith("remaining coins"):
            myBoard.RemainingCoins = int(value)
        if name.startswith("stopCriterion"):
            myBoard.StopCriterion = value
        if name.startswith("numberOfCoins"):
            myBoard.MaximalCoins = int(value)
    
    for i,row in enumerate(myBoard.Map):
        for j,posPlayer in enumerate(row):
            if posPlayer in myBoard.PlayerList:
                myBoard.PlayerPositions[posPlayer] = (i,j)

    return myBoard
        
if __name__ == '__main__':
    #test the reader:
    fileName = sys.argv[1]
    myBoard = readBoard(fileName)
    print myBoard.StopCriterion
    print myBoard.MaximalCoins
    print myBoard.RemainingCoins
    print myBoard.PlayerCoins
    print myBoard.PlayerPositions
    print myBoard.PlayerList
    #print myBoard.Map



    
    

