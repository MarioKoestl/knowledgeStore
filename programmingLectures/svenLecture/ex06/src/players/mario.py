import argparse
import os.path
import sys




def printMatrix(matrix):
    print('\n'.join([''.join(['{:4}'.format(item) for item in row]) 
      for row in matrix]))
  
# return a list of all the found positions of the given symbol(is used to look for players or coins)
def findCurPos(symbol,matrix):
    return [(index, row.index(symbol)) for index, row in enumerate(matrix) if symbol in row]

# only craete edges if the neighbour is a space or a doller sign
def createGraphDictionary(matrix): #https://www.python.org/doc/essays/graphs/
    graph={}
    
    numrows = len(matrix)
    numcols = len(matrix[0])
    for row_n,row in enumerate(matrix):
        for col_n,item in enumerate(row):
            neighbours = getAllNeighbours(matrix,row_n,col_n)
             
            #create new neighbourlist to only contain free places or the $ sign
            prunedNeighbour = [(ne[1],ne[2]) for ne in neighbours if ne[0] == ' ' or ne[0] == '$']

            #print neighbours,"\n"
            #print prunedNeighbour
            
            graph.update({(row_n,col_n): prunedNeighbour})
    return graph

#get all neighbours, set to other side of matrix if border was crosed
def getAllNeighbours(matrix,row_n,col_n):
    numrows = len(matrix)
    numcols = len(matrix[0])
    
    neighbours=[]
    #N neighbours
    if(row_n -1 >= 0):
        neighbours.append((matrix[row_n-1][col_n],row_n-1,col_n))
    else:
        neighbours.append((matrix[numrows-1][col_n],numrows-1,col_n))
    #E neighbour
    if(col_n +1 < numcols):
        neighbours.append((matrix[row_n][col_n+1],row_n,col_n+1))
    else:
        neighbours.append((matrix[row_n][0],row_n,0))
    #S neighbour
    if(row_n +1 < numrows):
        neighbours.append((matrix[row_n+1][col_n],row_n+1,col_n))
    else:
        neighbours.append((matrix[0][col_n],0,col_n))
     #W neighbour
    if(col_n-1 >= 0):
        neighbours.append((matrix[row_n][col_n-1],row_n,col_n-1)) 
    else:
        neighbours.append((matrix[row_n][numcols-1],row_n,numcols-1))
    
    return neighbours
    
def find_shortest_path(graph, start, end, path=[]):
    #print "find_shortest_path(%s ,%s ,%s\n" %(start,end,path)
    path = path + [start]
    if start == end:
        return path
    if not graph.has_key(start):
        return None
    shortest = None
    for node in graph[start]:
        if node not in path:
            newpath = find_shortest_path(graph, node, end, path)
            if newpath:
                if not shortest or len(newpath) < len(shortest):
                    shortest = newpath
    return shortest

#checks every shortest path to every coin on the map, and chooses the minimal path with the minimal steps to get there
def find_path_to_nearest_coin_path(matrix,graph,start):
    coinPositions = findCurPos('$',matrix)
    #print "found all coin positions", coinPositions
    possiblePaths=[]
    for coin in coinPositions:
        #print "try to find shortest path from %s to %s" % (start,coin)
        possiblePaths.append(find_shortest_path(graph,start,coin))
        
    
    #take only the path to the nearest coin
    
    return min(possiblePaths,key=len)    # gets the path with minimal length from all shortest paths to each coin, now we know which coin is the nearest one
    
def chooseNextMove(matrix,graph,ownSymbol):
    
    #change behaviour??
    
    
    numrows = len(matrix)
    numcols = len(matrix[0])
    
    #check path to nearest coin
    curPlayerPos = findCurPos(ownSymbol,matrix)[0]
    #print "found currentPosition of own player", curPlayerPos
    pathToNearestCoin= find_path_to_nearest_coin_path(matrix,graph,curPlayerPos)
    #print "found path to nearestCoin", pathToNearestCoin
    
    nextMovePosition = pathToNearestCoin[1]
    #print "curPosition(%i,%i)" %(curPlayerPos[0],curPlayerPos[1])
    #print "nextPosition(%i,%i)" %(nextMovePosition[0],nextMovePosition[1])
    nextMove = ''
    if((nextMovePosition[0] < curPlayerPos[0] and nextMovePosition[0] - curPlayerPos[0] == -1) or (nextMovePosition[0] == numrows-1 and curPlayerPos[0] == 0 )): # should go to the north, just simple or ever the egdge of the map
        nextMove='N'
    if((nextMovePosition[0] > curPlayerPos[0] and nextMovePosition[0]-curPlayerPos[0] == 1) or (nextMovePosition[0] == 0 and curPlayerPos[0] ==  numrows-1)): # go south
        nextMove='S'
    if((nextMovePosition[1] > curPlayerPos[1] and nextMovePosition[1] - curPlayerPos[1] == 1) or (nextMovePosition[1] == 0 and curPlayerPos[1] ==  numcols-1)): # go east
        nextMove='E'
    if((nextMovePosition[1] < curPlayerPos[1] and nextMovePosition[1] - curPlayerPos[1] == -1) or (nextMovePosition[1] == numcols-1 and curPlayerPos[1] ==  0)): # go west
        nextMove='W'
    #check path to nearest player that can be pushed in a water
    
    
    
    #check path to hideout if other player is near and i'm surrounded by water
    return nextMove

def getMatrixFromCurBoard(curBoardPath):
    d={}
    key=""
    matrix=[]
    with open(curBoardPath) as f:
        for line in iter(f):
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
   
    for line in d["board"]:
        matrix.append(line.replace("\n",''))
        
    return matrix

###anderer spieler ist schon aufn weg --> kein weg gefunden
# parsing
parser = argparse.ArgumentParser(description="Marios findShortestPath",conflict_handler="resolve")
parser.add_argument('-p', '--player', required=True, help='symbol of player')
parser.add_argument('-b', '--board', required=True, help='Path to file that contains the board encoded as text.')
parser.add_argument('-h', '--history', required=True, help='history file path')
args = parser.parse_args()
    

matrix = getMatrixFromCurBoard(args.board)
#printMatrix(matrix)
ownSymbol = args.player

graph = createGraphDictionary(matrix)
#print "finishedCreating Graph\n"
print chooseNextMove(matrix,graph,ownSymbol)
#print "finished choosing next move\n"
# printMatrix(matrix)

      