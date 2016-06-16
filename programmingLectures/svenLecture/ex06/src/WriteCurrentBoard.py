import logging

def writeCurrentBoard(pathToOutputFile, board, configs, option= None):
    """
    Write current status of the board to a file in given directory.
    :return: Nothing
    """
    matrix = board.getMatrix()
    
    out= "--------------------------\n"
    #defining the matrix
    out+="board:\n"
    for row in matrix:
        for column, data in enumerate(row):
            out += data
        out += "\n"
     
    #defining the configs
    out+= "configs:\n"
    out+="stopCriterion:%s\n" % configs.stopCriterion
    out+="numberOfCoins:%s\n" % configs.numberOfCoins
           
    #defining board data
    out+="board data:\n"
    out+="remaining coins:%s\n" % board.getRemainingCoins()
    out+="player coins:\n"
    for name in board.playerInfo:
        playerInfo = board.playerInfo[name]
        out+= "%s:%s\n" % (playerInfo.Name,playerInfo.Coins)
   
   
    # write out current board with all information (board, players, player sequence, coins per player, remaining coins, general playing configs)
    
    out+="--------------------------\n"
    

    if(option == "append"): #if this function is called from writeHistory
        with open(pathToOutputFile,'a') as file_out: # create or overwrite
            logging.debug(file_out)
            file_out.write(out)
        file_out.close()
    
    elif(option == None):
        with open(pathToOutputFile,'w+') as file_out: # create or overwrite
            logging.debug(file_out)
            file_out.write(out)
        file_out.close()
 
def writeCurrentBoardToSTDOUT(board, configs):
    """
    Write current status of the board to a file in given directory.
    :return: Nothing
    """
    matrix = board.getMatrix()
    
    out= "--------------------------\n"
    #defining the matrix
    out+="board:\n"
    for row in matrix:
        for column, data in enumerate(row):
            out += data
        out += "\n"
     
    #defining the configs
    out+= "configs:\n"
    out+="stopCriterion:%s\n" % configs.stopCriterion
    out+="numberOfCoins:%s\n" % configs.numberOfCoins
           
    #defining board data
    out+="board data:\n"
    out+="remaining coins:%s\n" % board.getRemainingCoins()
    out+="player coins:\n"
    for name in board.playerInfo:
        playerInfo = board.playerInfo[name]
        out+= "%s:%s\n" % (playerInfo.Name,playerInfo.Coins)
   
   
    # write out current board with all information (board, players, player sequence, coins per player, remaining coins, general playing configs)
    
    out+="--------------------------\n"
    
    print out    
    
