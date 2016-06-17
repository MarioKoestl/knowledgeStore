import argparse
import os.path
import os
import sys
from dijkstra import *
from operator import itemgetter

#mainDir = os.getcwd()
#sys.path.insert(0,mainDir) # import filereader from parent directory with execution from parent
import FileReader


def printMatrix(matrix):
    print('\n'.join([''.join(['{:4}'.format(item) for item in row]) 
      for row in matrix]))
  
# only craete edges if the neighbour is a space or a doller sign

def createGraphDictionary(matrix):
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
    

#checks every shortest path to every coin on the map, and chooses the minimal path with the minimal steps to get there
def find_path_to_nearest_coin_path(matrix,graph):
    #print "found all coin positions", coinPositions
    possiblePaths=[]
    for coin in coinPositions:
        #print "try to find shortest path from %s to %s" % (posPlayer,coin)
        possiblePaths.append(shortestPath(graph, tuple(posPlayer), tuple(coin)))  # from dijkstra
        
    #take only the path to the nearest coin
    return min(possiblePaths,key=len)    # gets the path with minimal length from all shortest paths to each coin, now we know which coin is the nearest one

def find_path_to_wealthiest_Enemy(matrix,graph):
    return shortestPath(graph,tuple(posPlayer),tuple(enemyPos))

def chooseNextMove(matrix,graph):
    wealthiestPlayer= getPlayerWithMostCoins(currentBoard)
    wealthiestCoins=int(currentBoard.PlayerCoins[getPlayerWithMostCoins(currentBoard)])
    cutoff = int(currentBoard.MaximalCoins)/int(len(currentBoard.PlayerList))
    
    if((int(ownCoins) > cutoff) or (wealthiestPlayer != args.player and wealthiestCoins > cutoff)) :
        pathToEnemyWithMostCoins=  find_path_to_wealthiest_Enemy(matrix,graph)
        if(pathToEnemyWithMostCoins):
            nextMovePosition= pathToEnemyWithMostCoins[1]
            #print'to the enemy 1'
        else:
            pathToNearestCoin= find_path_to_nearest_coin_path(matrix,graph)
            nextMovePosition= pathToNearestCoin[1]
            #print "to the coin1"
    else:
        pathToNearestCoin= find_path_to_nearest_coin_path(matrix,graph)
        if(pathToNearestCoin):
            nextMovePosition= pathToNearestCoin[1]
            #print "tothecoin2"
        else:
            pathToEnemyWithMostCoins=  find_path_to_wealthiest_Enemy(matrix,graph)
            nextMovePosition= pathToEnemyWithMostCoins[1]
           # print "totheenemy2"
       
    

    
    
    #check path to hideout if other player is near and i'm surrounded by water
    return convertPosIntoMoves(matrix,posPlayer,nextMovePosition)

def convertPosIntoMoves(matrix,curPos,nextMovePosition):
    numrows = len(matrix)
    numcols = len(matrix[0])
    nextMove = ''
    if((nextMovePosition[0] < curPos[0] and nextMovePosition[0] - curPos[0] == -1) or (nextMovePosition[0] == numrows-1 and curPos[0] == 0 )): # should go to the north, just simple or ever the egdge of the map
        nextMove='N'
    if((nextMovePosition[0] > curPos[0] and nextMovePosition[0]-curPos[0] == 1) or (nextMovePosition[0] == 0 and curPos[0] ==  numrows-1)): # go south
        nextMove='S'
    if((nextMovePosition[1] > curPos[1] and nextMovePosition[1] - curPos[1] == 1) or (nextMovePosition[1] == 0 and curPos[1] ==  numcols-1)): # go east
        nextMove='E'
    if((nextMovePosition[1] < curPos[1] and nextMovePosition[1] - curPos[1] == -1) or (nextMovePosition[1] == numcols-1 and curPos[1] ==  0)): # go west
        nextMove='W'
    return nextMove

def getPlayerWithMostCoins(currentBoard):
    maxP = None
    maxC = -1
    for p in currentBoard.PlayerList:
        if p != args.player:
            coins = currentBoard.PlayerCoins[p]
            if coins > maxC:
                maxC = coins
                maxP = p
    
    return maxP

def findCurPos(symbol,matrix):
    return [(index, row.index(symbol)) for index, row in enumerate(matrix) if symbol in row]

# parsing
parser = argparse.ArgumentParser(description="Marios findShortestPath",conflict_handler="resolve")
parser.add_argument('-p', '--player', required=True, help='symbol of player')
parser.add_argument('-b', '--board', required=True, help='Path to file that contains the board encoded as text.')
parser.add_argument('-h', '--history', required=True, help='history file path')
args = parser.parse_args()
    
currentBoard = FileReader.readBoard(args.board)
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
enemyPos = currentBoard.PlayerPositions[getPlayerWithMostCoins(currentBoard)]
posPlayer = currentBoard.PlayerPositions[args.player]
ownCoins = currentBoard.PlayerCoins[args.player]
coinPositions = findCurPos('$',matrix)

graph = createGraphDictionary(matrix)
#print "finishedCreating Graph\n"
#printMatrix(matrix)
print chooseNextMove(matrix,graph)
#print "finished choosing next move\n"


      