#!/usr/bin/python

'''
python Wechselgeld-gEntzian.py -b<int> -c<space-separated coins (int)>
Purpose: Compute the change-problem with dynamic programming.
@author GE
'''

import argparse
import re  
import sys
import math

# arguments:
parser = argparse.ArgumentParser(description='This program computes the change-problem with dynamic programming.')
parser.add_argument("-c", "--change", action="store", type=int, required=True, help="change as int.")
parser.add_argument("-d", "--coindenomination", action="store", type=int, nargs='+', required=True, help="coin denomination as integer vector.")
parser.add_argument("-v", "--verbose", action="store_true", required=False, help="verbose.")
args = parser.parse_args()

# read values
change = args.change
coins = args.coindenomination
print change

coins.sort()
print coins
solutionTable = [[[()] for x in range(change+1)] for x in range(len(coins)+1)]
changeMatrix = [[0 for x in range(change+1)] for x in range(len(coins)+1)]
for i in range(change+1):
    changeMatrix[0][i] = i
def changeMoney(change, coins): 
    for coinIndex in range(1, len(coins) + 1):
        for subChange in range(1, change + 1):
            if coins[coinIndex - 1] == subChange:
                changeMatrix[coinIndex][subChange] = 1
                solutionTable[coinIndex][subChange] = [(coins[coinIndex-1],)]# add 1 coin for exact match
            elif coins[coinIndex - 1] > subChange:
                changeMatrix[coinIndex][subChange] = changeMatrix[coinIndex - 1][subChange]
                solutionTable[coinIndex][subChange] = solutionTable[coinIndex-1][subChange] # add solution from upper cell.
            else:
                changeMatrix[coinIndex][subChange] = min(changeMatrix[coinIndex - 1][subChange], 1 + changeMatrix[coinIndex][subChange - coins[coinIndex - 1]])
                # add solution with minimal coins
                optionOne = solutionTable[coinIndex-1][subChange] # from upper cell
                optionTwo = []
                for subSolution in solutionTable[coinIndex][subChange-coins[coinIndex-1]]:
                    newSubSolution = (coins[coinIndex-1],) + subSolution
                    optionTwo.append(newSubSolution)  # coin + from cell[coin,subchange-coin]
                if coinIndex == 1: # first row --> option one is empty
                    solutionTable[coinIndex][subChange] = optionTwo
                #elif(len(optionOne[0]) < len(optionTwo[0])): #compare only one of the subsolution per cell, because all should have the same number of coins
                #    solutionTable[coinIndex][subChange] = optionOne
                #elif(len(optionOne[0]) > len(optionTwo[0])):
                #    solutionTable[coinIndex][subChange] = optionTwo
                else:
                    if args.verbose:
                        print 'multiple solutions possible:',optionOne,optionTwo
                    solutionTable[coinIndex][subChange] = optionOne + optionTwo

    if args.verbose:
        print changeMatrix
    return changeMatrix[-1][-1]


print changeMoney(change,coins)

if args.verbose:
    print solutionTable
test = solutionTable[3]
solution = solutionTable[len(coins)][change]
HasSolution=False
minCoins = sys.maxint
for s in solution:
    rest = change-sum(s)
    if rest == 0:
        minCoins = min(minCoins,len(s))
for s in solution:
    rest = change-sum(s)
    if rest == 0 and len(s) == minCoins:
        print 'change coins:',s
        HasSolution = True
    
if not HasSolution:
    print "Sorry, there is no exact solution."
    
    
    
    
    
    
    
    
    
    
    
