import random
import sys
import os
import argparse
from dijkstra import *
from operator import itemgetter
from scipy.sparse.csgraph._shortest_path import shortest_path
from copy import copy

mainDir = os.getcwd()
#index = scriptPath.rfind('/')
#fileReaderPath = scriptPath[0:index]
#print fileReaderPath
sys.path.insert(0,mainDir) # import filereader from parent directory with execution from parent
#sys.path.insert(0,mainDir+'/..') # import filereader from parent directory with execution from botDir
import FileReader
import math

# arguments:
parser = argparse.ArgumentParser(description='myBot', conflict_handler='resolve')
parser.add_argument("-p", "--player", action="store", type=str, required=True, help="Character on the map")
parser.add_argument("-b", "--boardFile", action="store", type=str, required=True, help="BoardFile.")
parser.add_argument("-h", "--historyFile", action="store", type=str, required=True, help="HistoryFile.")


def readLastPosition():
    directoryBot = os.path.dirname(os.path.realpath(__file__))
    tmpPositionFile = os.path.join(directoryBot,"ge_LastPosition.txt")
    file = open(tmpPositionFile,'r+')
    pos = file.readline()
    file.close()
    numbers = pos[1:len(pos)-1]
    numbers = numbers.split(',')
    numbers = [int(x) for x in numbers]
    position = tuple(numbers)
    return position


def blockLastPositionIfMoveFailed(matrix, currentBoard):
    lastPos = readLastPosition()
    playerPos = currentBoard.PlayerPositions[Name]
    if lastPos != playerPos:
        x,y = lastPos
        matrix[x][y] = '^' #block position of unsuccessful move
        
        
def matrixToGraph(matrix):
    dictVertices = {}
    rows = len(matrix)
    cols = len(matrix[0])
    #add all cells
    for i,row in enumerate(matrix):
        for j,cellValue in enumerate(row):
            if cellValue == ' ' or cellValue == '$' or cellValue in currentBoard.PlayerList:
                cell = (i,j) 
                dictVertices[cell] = {}
    #add all neighbors
    for k in dictVertices.keys():
        i, j = k
        neighbors = [[i-1,j], [i+1,j], [i,j-1], [i,j+1]]
        
        # if walk through map borders is allowed:       
        for i in range(len(neighbors)):
            if neighbors[i][0] >= rows:
                neighbors[i][0] = 0
            if neighbors[i][0] < 0:
                neighbors[i][0] = rows-1
            if neighbors[i][1] >= cols:
                neighbors[i][1] = 0
            if neighbors[i][1] < 0:
                neighbors[i][1] = cols-1
             
        for n in neighbors:
            nn = tuple(n)
            if nn in dictVertices.keys(): # == if move is allowed
                dictVertices[k][nn] = 1 #length from a vertex to its neighbors is 1
    
    return dictVertices


def searchCoinPositions(matrix):
    posCoins = []
    for i,l in enumerate(matrix):
        for j,c in enumerate(matrix[i]):
            if '$' == matrix[i][j]:
                posCoin = [i,j]
                posCoins.append(posCoin)
    return posCoins
         

def parsePositionsToDirection(posPlayer,posNextCell):
    x, y = tuple(posPlayer)
    xc,yc = tuple(posNextCell)
    if x < xc:
        bestOption = 'S'
    if x > xc:
        bestOption = 'N'
    if y < yc:
        bestOption = 'E'
    if y > yc:
        bestOption = 'W'   
    # handle walk through border
    rowMax = len(matrix)-1
    colMax = len(matrix[0])-1
    if (x >= rowMax) and (xc == 0):
        bestOption = 'S' 
    if (xc >= rowMax) and (x == 0):
        bestOption = 'N'
    if (y >= colMax) and (yc == 0):
        bestOption = 'E'
    if (yc >= colMax) and (y == 0):
        bestOption = 'W'
    return bestOption


def writeLastPosition(pos):
    directoryBot = os.path.dirname(os.path.realpath(__file__))
    tmpPositionFile = os.path.join(directoryBot,"ge_LastPosition.txt")
    file = open(tmpPositionFile,'w+')
    file.write(str(pos))
    file.close()


def getMovableDirections(pos,graph):
    i,j = pos
    rows = len(matrix)
    cols = len(matrix[0])
    neighbors = [[i-1,j], [i+1,j], [i,j-1], [i,j+1]]       
    # if walk through map borders is allowed:       
    for i in range(len(neighbors)):
        if neighbors[i][0] >= rows:
            neighbors[i][0] = 0
        if neighbors[i][0] < 0:
            neighbors[i][0] = rows-1
        if neighbors[i][1] >= cols:
            neighbors[i][1] = 0
        if neighbors[i][1] < 0:
            neighbors[i][1] = cols-1
            
    allowedMoves = []
    for n in neighbors:
            nn = tuple(n)
            if nn in graph.keys():  # is allowed
                direction = parsePositionsToDirection(pos,nn)
                allowedMoves.append(direction)
    return allowedMoves


def addRandomMoveToAvoidDeadLocks(pos,direction, graph):
    moves = getMovableDirections(pos, graph)
    options = []
    for m in moves:
        options += [m]*1
    options += [direction]*6
    print >> sys.stderr, (options,"moves")
    return random.choice(options)


if __name__ == "__main__":
    
    args = parser.parse_args()
    Name = args.player
    BoardFile = args.boardFile
    HistoryFile = args.historyFile 
    currentBoard = FileReader.readBoard(BoardFile)
    '''BoardInfo Properties
        # c == after all coins are collected; d == after one player has 10 coins (infinite coins)
        StopCriterion = c or p
        MaximalCoins = int
        RemainingCoins = int
        PlayerCoins = {}
        PlayerPositions = {}
        PlayerList = []
        Map = [[]]
    '''
    matrix = currentBoard.Map
    blockLastPositionIfMoveFailed(matrix,currentBoard)
                    
    graph = matrixToGraph(matrix)
      
    posPlayer = currentBoard.PlayerPositions[Name]
    posCoins = searchCoinPositions(matrix)
    
    #compute own distances to all coins
    minDist = int(sys.float_info.max)
    coinList = []
    for posCoin in posCoins:
        sp = shortestPath(graph, tuple(posPlayer), tuple(posCoin))
        dist = len(sp)
        coinList.append((tuple(posCoin),dist))
    
    coinList = sorted(coinList, key=itemgetter(1))
    
    #compute enemies distances to coins.
    coinsToCoinsider = list(coinList)
    for p in currentBoard.PlayerPositions.keys():
        if p != Name:
            #it is an enemie
            ePos = currentBoard.PlayerPositions[p]
            minDist = sys.float_info.max
            bestCoin = None
            enemiesDist = sys.float_info.max
            for coinAndDist in coinsToCoinsider:
                sp = shortestPath(graph,ePos,coinAndDist[0])
                if len(sp) < minDist:
                    minDist = len(sp)
                    bestCoin = coinAndDist
                    enemiesDist = len(sp)
            if bestCoin != None and coinAndDist[0] > enemiesDist:
                coinsToCoinsider.remove(bestCoin)
    
    myBestCoin = None
    if len(coinsToCoinsider) > 0:
        myBestCoin = coinsToCoinsider[0][0]          
    elif len(coinList) > 0:
        myBestCoin = coinList[0][0]
             
    if myBestCoin == None:
        moves = ["N", "S", "W", "E"]
        print >> sys.stderr, ('X',coinList)
        # TODO: follow the player with the most coins and push him
        #print random.choice(moves)
        exit()

    #search for path to coin
    #print graph
    sp = shortestPath(graph, tuple(posPlayer), tuple(myBestCoin))
    print >> sys.stderr, sp
    nextCell = sp[1]
    
    bestOption = parsePositionsToDirection(tuple(posPlayer),nextCell)
    writeLastPosition(nextCell)
    
    #TODO: Stay away from the water
    #TODO: Find another way! Random moves are not good.
    #bestOption = addRandomMoveToAvoidDeadLocks(tuple(posPlayer),bestOption, graph)

    print bestOption

