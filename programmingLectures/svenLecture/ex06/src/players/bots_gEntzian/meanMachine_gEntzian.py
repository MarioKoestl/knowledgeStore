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


def getPlayerPosWithMostCoins(currentBoard):
    maxP = None
    maxC = -1
    for p in currentBoard.PlayerList:
        if p != Name:
            coins = currentBoard.PlayerCoins[p]
            if coins > maxC:
                maxC = coins
                maxP = p
    
    return currentBoard.PlayerPositions[maxP]


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
    graph = matrixToGraph(matrix)
    
    enemyPos = getPlayerPosWithMostCoins(currentBoard)
    posPlayer = currentBoard.PlayerPositions[Name]
    sp = shortestPath(graph, tuple(posPlayer), tuple(enemyPos))
    #print >> sys.stderr, sp
    nextCell = sp[1]
    direction = parsePositionsToDirection(posPlayer,nextCell)
        
    print direction

