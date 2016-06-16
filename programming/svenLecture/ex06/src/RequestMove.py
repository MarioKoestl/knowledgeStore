from subprocess import Popen, PIPE
import os, logging

def requestPlayersMoveInternal( player, board, configs, boardFile, historyFile):
    """
    Request move from a player by calling a standardized shell script
    which in turn calls the player client program.
    :return: Player's move as one of the letters 'N', 'S', 'W', 'E' or None
    """

    path = board.getPlayerShellScriptPath(player)
    path = adjustPathsToOS(path)
    boardFile = adjustPathsToOS(boardFile)
    historyFile = adjustPathsToOS(historyFile)
    callParams = [path,
                  "-p", player,  # -p {Character} ... The character representing the called player
                  "-b", boardFile,  # -b {Path to current board file}
                  "-h", historyFile]  # -h {Path to the history file}

    # http://stackoverflow.com/questions/20810366/executing-shell-script-using-subprocess-popen-in-python
    # https://docs.python.org/2/library/subprocess.html#frequently-used-arguments
    callParams = " ".join(callParams)
    (stdout, stderr) = Popen(callParams, stdout=PIPE, shell=True).communicate()
    logging.debug(stderr)
    stdout = stdout.strip()
    
    if stdout in ["N","E","S","W"]:
        return stdout
    return None

def adjustPathsToOS(path):
    s = path.split(' ')
    if len(s) > 1:
        #assume first part is tool, second part is path
        return s[0]+' '+os.path.abspath(s[1])
    else:
        return os.path.abspath(path)