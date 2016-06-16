import random
import sys
import os
import argparse
mainDir = os.getcwd()
#index = scriptPath.rfind('/')
#fileReaderPath = scriptPath[0:index]
#print fileReaderPath
sys.path.insert(0,mainDir) # import filereader from parent directory
import FileReader
import math

# arguments:
parser = argparse.ArgumentParser(description='myBot', conflict_handler='resolve')
parser.add_argument("-p", "--player", action="store", type=str, required=True, help="Character on the map")
parser.add_argument("-b", "--boardFile", action="store", type=str, required=True, help="BoardFile.")
parser.add_argument("-h", "--historyFile", action="store", type=str, required=True, help="HistoryFile.")
args = parser.parse_args()


#moves = ["N", "S", "W", "E"]
#print random.choice(moves)
Name = args.player
BoardFile = args.boardFile
HistoryFile = args.historyFile 
board = FileReader.readBoard(BoardFile)
matrix = board.Map

Coin = '$'

def canMovePlayer(position):
    x,y = tuple(position)
    if(x < len(matrix) and y < len(matrix[0])):
        fieldType = matrix[x][y]
        if(fieldType == ' ' or fieldType == Coin):
            return True
        else:
            return False
    return False

#search player and coins
posPlayer = [0,0]
posCoins = []
for i,l in enumerate(matrix):
    if Name in l:
        posPlayer = [i, l.index(Name)]
    if Coin in l:
        posCoin = [i, l.index(Coin)]
        posCoins.append(posCoin)

#search closest coin
minDist = int(sys.float_info.max)
bestCoin = None
for posCoin in posCoins:
    x, y = tuple(posPlayer)
    xx, yy = tuple(posCoin)
    
    dist = math.pow(x-xx,2)+math.pow(y-yy,2)
    if dist < minDist:
        minDist = dist
        bestCoin = [xx, yy]

#search for path to coin
north = list(posPlayer)
south = list(posPlayer)
east = list(posPlayer)
west = list(posPlayer)
north[0] -= 1
south[0] += 1
east[1] += 1
west[1] -= 1
options = [north,south,east,west]
bestOption = 0

minDist = int(sys.float_info.max)
bestOption = 'N'
for i,o in enumerate(options):
    x, y = tuple(o)
    xx,yy = tuple(bestCoin)
    if canMovePlayer((xx,yy)):
        dist = math.pow(x-xx,2)+math.pow(y-yy,2)
        if dist < minDist:
            minDist = dist
            if i == 0:
                bestOption = 'N'
            if i == 1:
                bestOption = 'S'
            if i == 2:
                bestOption = 'E'
            if i == 3:
                bestOption = 'W'
                


print bestOption
