from random import randint, shuffle
import copy
from RequestMove import requestPlayersMoveInternal
from WriteHistory import writeHistory
import FileReader
#from gui.gui import *
import os, time, logging
import subprocess
from _sqlite3 import Row


class Player(object):
    def __init__(self,name,filePath):
        self.Position = (0,0)
        self.Coins = 0
        self.Name = name
        self.FilePath = filePath


class Board(object):
    def __init__(self):
        self.matrix = []
        self.players = []
        # list of Player objects, which show their current position, name and path. The index is the initial character
        self.playerInfo = {}
        self.coins = 10
        self.coinsOfDrownedPlayers = 0
        self.configs = None
        self.shuffledPlayers = []
        self.updateTime = 0.1

    def init(self, pathToBoardFile, configs, pathToPlayerFile = None):
        """
        This function is called to initialize the Board from a board-file or a status-file.
        If the pathToPlayerFile parameter is given, the first parameter is interpreted as the path to the board-file
        If the pathToPlayerFile parameter is omitted, the first parameter is interpreted as the path to the status-file
        :param pathToBoardFile: Path to board-file/status-file
        :param pathToPlayerFile: Path to the file of players
        :return:
        """
        if pathToPlayerFile is None:
            # can be called by player programs, is able to extract the information in the boardCurrent file
            # now this functions create only the matrix, but player infos and config infos could also be stored, but where( should player objects be created??)
            d={}
            key=""
            with open(os.path.join(pathToOutputDirectory,"boardCurrent.txt")) as f:
                for line in iter(f):
                    logging.debug( "reading line ",line)
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
                self.matrix.append(line)
        else:
            #config
            self.configs = configs
            self.coins = int(configs.numberOfCoins)
            self.updateTime = float(configs.waitingTime)
            
            #store board from Board File to matrix, this file will be read only once 
            self.matrix = FileReader.readMap(pathToBoardFile)
            
            #store players from File in list players: list of tuples(character, path to shell script)
            with open(pathToPlayerFile) as playerFile:
                
                for row in playerFile:
                    rowSplits = row.split('\t')
                    self.players.append((rowSplits[0], rowSplits[1].rstrip('\n')))
            playerFile.close()
            
            #create player info list
            for i in range(len(self.players)):
                charPlayer, filePlayer = self.players[i]
                self.playerInfo[charPlayer] = Player(charPlayer,filePlayer)
                    
            #add players from Player File at random positions
            size = len(self.matrix)
            size2 = len(self.matrix[0])
            for p in self.players:
                index1 = randint(0,size-1)
                index2 = randint(0,size2-1)
                while(self.matrix[index1][index2] != ' '):
                    index1 = randint(0,size-1)
                    index2 = randint(0,size2-1)
                if self.matrix[index1][index2] == ' ':
                    self.matrix[index1][index2] = p[0]
                    self.playerInfo[p[0]].Position = (index1,index2)
            
            
    def initRound(self):
        """
        Do the stuff, which is needed on the beginning of every round
        """
        self.shuffledPlayers = list(self.players)
        shuffle(self.shuffledPlayers)


    def getMatrix(self, omitCoins = False, omitPlayers = False):
        """
        Creates a 2D list representation of the Board
        Accessing the result like x[i][j] for the i-th row and j-th column
        :param omitCoins: When set to True, position with a coin on it are represented as empty
        :param omitPlayers: When set to True, positions with a player on it are represented as empty
        :return: 2D list of characters
        """
        if(omitCoins == False and omitPlayers == False):
            return self.matrix
        else:
            retMatrix = [[0 for i in xrange(len(self.matrix[0]))] for i in xrange(len(self.matrix))]
 
            for row_n,row in enumerate(self.matrix):
                for column, data in enumerate(row):
                    value = data
                    if(data == "$" and omitCoins == True):    
                        value = " "
                    if(data != "$" and data != "~" and data != " " and data != "^" and omitPlayers == True): #can only be a player char
                        value= " "
                    
                    retMatrix[row_n][column] = value
            return retMatrix       

    def getPlayers(self):
        """
        Returns the complete list of players
        :return: list of characters
        """
        listOfPlayers = [ x[0] for x in self.players]
        return listOfPlayers

    def getPlayersSequence(self):
        """
        Returns the list of the players in the order they will by called
        :return: list of tuples (character, path to shell script)
        """
        shuffled = list(self.players)
        shuffle(shuffled)

        # print "PLAYERS: ", self.players, "SHUFFLED: ", shuffled
        return shuffled

    def getPlayerPosition(self, player):
        """
        Returns the position of a player as a tuple (i,j) which means the i-th row and the j-th column
        :param player: The character representing the player
        :return: (i,j)
        """
        return self.playerInfo[player].Position

    def getCoinsCount(self, player):
        """
        Returns the amount of coins of a given player
        :param player: The character representing the player
        :return: The amount of coins
        """
        return self.playerInfo[player].Coins

    def getCoinsPositions(self):
        """
        Returns the positions (i,j) of the free coins on the board
        :return: a list of tuples (i,j)
        return list of length 0  if no coin found (in order the last coin was picked up by a player, needed for finish criteria)
        """
        return [(index, row.index('$')) for index, row in enumerate(self.matrix) if '$' in row]
        

    def getRemainingCoins(self):
        """
        Returns the amount of remaining coins, which are on the stack
        :return: The amount of coins
        """
        return self.coins

    def canMovePlayer(self, player, direction):
        """
        Returns if a move is possible
        :param player: The character representing the player
        :param direction: a character of 'N', 'S', 'W', 'E'
        :return: True, if the move is possible, otherwise False
        """
        x,y = self.getNewPosition(player, direction)
        if(x < len(self.matrix) and y < len(self.matrix[0])):
            return True
        return False

    def getSuspendedPlayers(self):
        """
        Returns a list of players, which are currently suspended, i.e. fell into water
        :return: List of player characters
        """
        
    def containsSuspendedPlayers(self):
        """
        Returns if a player is suspended, i.e. fell into water
        :return: True, if a player is suspended, otherwise False
        """
    
    def chooseValidRandomPosition(self):
        size = len(self.matrix)
        size2 = len(self.matrix[0])
        index1 = randint(0,size-1)
        index2 = randint(0,size2-1)
        while(self.matrix[index1][index2] != ' '):
            index1 = randint(0,size-1)
            index2 = randint(0,size2-1)
        if self.matrix[index1][index2] == ' ':
            return (index1,index2)

    
    def resetPlayer(self,player,guiGame):
        logging.debug("reset player: ", player)
        playerObject = self.playerInfo[player]
        playerIndex = self.players.index((playerObject.Name,playerObject.FilePath))
        oldPosition = playerObject.Position
        newPosition = self.chooseValidRandomPosition()
        playerObject.Position = newPosition
        #board reset
        #board move
        x, y = oldPosition
        self.matrix[x][y] = ' '
        x, y = newPosition
        self.matrix[x][y] = player
        #loose coins (board)
        self.coinsOfDrownedPlayers += playerObject.Coins
        playerObject.Coins = 0
        
        if guiGame != None:
            #gui reset
            guiGame.removeItemFromCell(oldPosition)
            time.sleep(self.updateTime)
            guiGame.addPlayerToCell(newPosition, playerIndex)
            #loose coins (gui)
            guiGame.updateCoinsRemaining(self.coins)
            guiGame.updateCoins(playerIndex,playerObject.Coins)
    
    def movePlayer(self, player, direction, guiGame):
        """
        Moves a player in the given direction
        :param player: The character representing the player
        :param direction: a character of 'N', 'S', 'W', 'E'
        """
        if(self.canMovePlayer(player, direction)):
            playerObject = self.playerInfo[player]
            playerIndex = self.players.index((playerObject.Name,playerObject.FilePath))
            oldPosition = playerObject.Position
            newPosition = self.getNewPosition(player,direction)  
            
            #test if it is water
            x2,y2 = oldPosition
            x, y = newPosition
            logging.debug("player = %s, direction = %s, old pos = (%s,%s), newPos = (%s,%s)" % (player,direction,x2,y2,x,y))
            if self.matrix[x][y] == '~': 
                self.resetPlayer(player, guiGame)
                return
            if self.matrix[x][y] == '^': # at a boarder do nothing with the player, just stand still
               return 
            
            #test if it is another player
            if self.matrix[x][y] != '~' and \
                self.matrix[x][y] != '^' and \
                self.matrix[x][y] != ' ' and \
                self.matrix[x][y] != '$':
                
                otherPlayer = self.matrix[x][y]
                if direction == 'N' or direction == 'S' or direction == 'W' or direction == 'E':
                    self.movePlayer(otherPlayer, direction, guiGame)
            
            #board move
            xx, yy = oldPosition
            self.matrix[xx][yy] = ' '
                        
            self.tryToPickupCoin(player,newPosition,guiGame)
            
            # update position on board
            x, y = newPosition
            self.matrix[x][y] = player
            
            if guiGame != None:
                #gui move
                guiGame.removeItemFromCell(oldPosition)
                guiGame.addPlayerToCell(newPosition, playerIndex)
            time.sleep(self.updateTime)
            
            playerObject.Position = newPosition
            
    def tryToPickupCoin(self,player,newPosition,guiGame):
        x,y = newPosition
        if(self.matrix[x][y] == '$'):
            self.matrix[x][y] = ' '
            playerObject = self.playerInfo[player]
            playerObject.Coins += 1
            playerIndex = self.players.index((playerObject.Name,playerObject.FilePath))
            # if a player pciked up a coin, a next coin should be on the board prior to the next player move call
            self.placeNewCoinIfNothingOnBoard(guiGame)
            if guiGame != None:
                guiGame.updateCoins(playerIndex,playerObject.Coins)
            
            
    def placeNewCoinIfNothingOnBoard(self, guiGame):
        coinsOnBoard = self.getCoinsPositions()
        if(len(coinsOnBoard) == 0 and self.coins):
            self.distributeCoins(1, guiGame)
            if(self.configs.stopCriterion == 'c'):
                self.coins -= 1
                if guiGame != None:
                    guiGame.updateCoinsRemaining(self.coins)
    
    def distributeCoins(self,n,guiGame):
        """
        random distribution of n coins
        """
        # count empty cells and set coins that cannot be placed on the stack
        emptyCells = 0
        for row in self.matrix:
            for cell in row:
                if cell == ' ':
                    emptyCells += 1
        rest = 0            
        if n > emptyCells:
            rest = n - emptyCells
            n = emptyCells
        self.coins +=rest
        if guiGame != None:
            guiGame.updateCoinsRemaining(self.coins)
        
        for i in range(n):
            size = len(self.matrix)
            size2 = len(self.matrix[0])
            index1 = randint(0,size-1)
            index2 = randint(0,size2-1)
            while(self.matrix[index1][index2] != ' '):
                index1 = randint(0,size-1)
                index2 = randint(0,size2-1)
            if self.matrix[index1][index2] == ' ':
                self.matrix[index1][index2] = '$'
                if guiGame != None:
                    guiGame.addCoinToCell((index1,index2))
                       
            
    def getNewPosition(self,player,direction):
        player = self.playerInfo[player]
        oldPosition = player.Position
        newPosition = oldPosition
        if(direction == "N"):
            newPosition = (oldPosition[0]-1,oldPosition[1])
        if(direction == "S"):
            newPosition = (oldPosition[0]+1,oldPosition[1])
        if(direction == "W"):
            newPosition = (oldPosition[0],oldPosition[1]-1)
        if(direction == "E"):
            newPosition = (oldPosition[0],oldPosition[1]+1)
        
        # walk in world without borders
        x, y = newPosition
        rows = len(self.matrix)
        cols = len(self.matrix[0])
        if x >= rows:
            x = 0
        if y >= cols:
            y = 0
        if x < 0:
            x = rows-1
        if y < 0:
            y = cols-1
        
        newPosition = (x,y)
        
        return newPosition

    def getPlayerShellScriptPath(self, player):
        """
        Returns the path to the shell script for a given player
        :param player: The character representing the player
        :return: The path as string
        """
        return [path for player_, path in self.players if player_ == player][0]

    def requestPlayersMove(self, player, config, boardFile, historyFile):
        """
        Request move from a player by calling a standardized shell script
        which in turn calls the player client program.
        :return: Player's move as one of the letters 'N', 'S', 'W', 'E'
        """

        # todo:
        # - request
        # - validity check

        return requestPlayersMoveInternal(player, self, config, boardFile, historyFile)

    def copy(self):
        """
        Creates a deep copy of the board
        :return: Board
        """
        return copy.deepcopy(self)