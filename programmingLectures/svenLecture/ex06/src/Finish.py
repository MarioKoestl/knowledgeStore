def gameIsFinished( configs, board ):
    """
    Check if chosen game termination condition is fulfilled
    :return: True if it is fulfilled, False otherwise
    """
    if(configs.stopCriterion == 'c' and board.getRemainingCoins() < 0 and len(board.getCoinsPositions()) == 0):
        
        return True
    if(configs.stopCriterion == 'p'):
        for player in board.getPlayers():
            if(board.getCoinsCount(player) >= configs.numberOfCoins):
                return True
    return False
