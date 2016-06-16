import argparse
import os.path
import sys

def parseCommandLineArguments():
    """
    Parse command line arguments provided on program call
    :return: paths to board file, player file, config file, output directory
    """
    
    # parsing
    parser = argparse.ArgumentParser(description="Torus runner.")
    parser.add_argument('-b', '--board', required=True, help='Path to file that contains the board encoded as text.')
    parser.add_argument('-p', '--players', required=True, help='Path to file that contains player names and absolute paths to the client programs.')
    parser.add_argument('-c', '--config', required=True, help='Path to file that contains the game configuration (number of coins, stop criterion).')
    parser.add_argument('-d', '--out-directory', required=True, help='Path to output directory in which current board and history are saved.')
    parser.add_argument('-history', '--history',required=False,help='1 = Creates a History file, 0 = no history, Default = no History')
    parser.add_argument('-g', '--without-gui', action="store_false", required=False,help='Prints the board on stdout. Use this if you cannot install the PIL.')
    parser.add_argument('-v', '--verbose', action="store_true", required=False,help='Prints additional info to the stdout.')
    args = parser.parse_args()
    
    # validity checks
    
    if not (os.path.isfile(args.board) and os.access(args.board, os.R_OK) ):
        print "ERROR, args.board is not a file or not readable\n";
        sys.exit()
    if not (os.path.isfile(args.players) and os.access(args.players, os.R_OK) ):
        print "ERROR, args.players is not a file or not readable\n";
        sys.exit()
    if not (os.path.isfile(args.config) and os.access(args.config, os.R_OK) ):
        print "ERROR, args.config is not a file or not readable \n";
        sys.exit()
    
    if os.path.exists(args.out_directory):
        if( not (os.access(args.out_directory, os.R_OK) and os.access(args.out_directory, os.W_OK))):
            print "ERROR, args.out_directory is not readable or writable\n";
            sys.exit()
    else:
        os.makedirs(args.out_directory) # create directory if not existing
    
    #append / if not available
    if args.out_directory[len(args.out_directory)-1] != '/':
        args.out_directory += '/'
    
    return args.board, args.players, args.config, args.out_directory, args.history, args.without_gui, args.verbose
