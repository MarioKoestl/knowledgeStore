import argparse
import re

class Configs:
    def __init__(self, stopCriterion, numberOfCoins, waitingTime):
        self.stopCriterion = stopCriterion
        self.numberOfCoins = numberOfCoins
        self.waitingTime = waitingTime
    
def parseConfigFile( pathToConfigFile ):
    """
    Parse game configuration parameters provided in config file
    :return: Object holding stopCriterion, numberOfCoins and waitingTime
    
    checks for a regex in the configsFile, first occurence is the valid configuration
    stopCriterion has to be a character either c or p
    numberOfCoins has to be a positiv integer
    waitingTime has to be any positiv number
    
    Default value if error or nothing found = c,10,500
    
    """
    
    config = Configs( "c",10,500);
    configList=[]
    
    with open(pathToConfigFile) as configFile:
        for line in configFile:
            match = re.search('[cp]\t\d+\t\d+\.\d+|[cp]\t\d+\t\d+',line);
            if match:
                configList = match.group().split('\t')
                break;
    
    if(len(configList) == 3):
        config.stopCriterion = configList[0]
        if(configList[1].isdigit() and configList[1] > 0):
            config.numberOfCoins = int(configList[1])
        if(configList[2] > 0):
            config.waitingTime = float(configList[2])
    return config
