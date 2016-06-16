from WriteCurrentBoard import *

def writeHistory( pathToOutputFile, rememberedBoards, configs ):
    """
    Append history of the last round to file in given directory.
    :return: Nothing
    """
    for board in rememberedBoards:
        writeCurrentBoard(pathToOutputFile, board, configs, "append" )
