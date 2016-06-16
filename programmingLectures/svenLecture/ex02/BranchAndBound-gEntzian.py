#!/usr/bin/python
'''
python BranchAndBound-gEntzian.py -f [input_file]
Purpose: This program reads a whitespace separated matrix with costs in millions/year.
        The first row contains two integers: number of cities and the maximal cost.
        The second row contains the names.
        The following rows are rows of the matrix.
        
        
@author GE
'''

import argparse
import re
import sys

#arguments:
parser = argparse.ArgumentParser(description='This program computes all feasible tuples below with costs below a threshold in mio/year with a \
            branch and bound algorithm. The costs for the tuples are taken from a matrix from the input file.')
parser.add_argument("-f", "--file", action="store", type=str, required=True, help="Input file with matrix.")
parser.add_argument("-t", "--threshold", action="store", type=int, required=False, help="Threshold in [mio/year].")
parser.add_argument("-v", "--verbose", action="store_true", required=False, help="More informations and solutions for each iteration.")
args = parser.parse_args()

#read matrix
columnNames = []
matrix = []
threshold = args.threshold
f = open(args.file, 'r')
for line in f:
    line.rstrip('\n')
    line = line.strip()
    match = re.search('^(\d+)\s+(\d+)',line)
    if match and threshold == None and not columnNames:
        #first line
        threshold = int(match.group(2))
        print 'Threshold: ', threshold
        continue
    match = re.search('^([\sA-z]+)#*',line)
    if match and not columnNames:
        #fill column descriptors
        names = match.group(1)
        columnNames = names.split()
        print 'Names: ', names
        continue
    match = re.search('^([-\d\s]+)#*',line)
    if match and columnNames:
        # fill matrix
        values = match.group(1)
        print 7*' ',values
        values = values.split()
        row = []
        for v in values:
            if v == '-':
                v = 0
            row.append(float(v))
        matrix.append(row)
f.close()

if(len(matrix) == 0):
    print("Error: Matrix is empty!")
    exit()
if(len(matrix[0]) != len(matrix)):
    print("Error: Number of rows and columns is different!")
    exit()
if(len(matrix)%2 != 0):
    print("Error: The matrix needs an even number of rows and columns!")
    exit()
if(len(columnNames) != len(matrix)):
    print("Error: The number of cities has to be the number of columns!")
    exit()
if(threshold == None):
    print("Error: No threshold given!")
    exit()
    
class counter:
    def __init__(self):
        self.count = 0
    def next(self):
        self.count += 1
        return self.count
c = counter()      
iterationCounter = counter()
def branchAndBound(statesToDistribute, matrix, threshold, costSum = 0, stack = []):
    '''
    prints all optimal solutions with costs below threshold in mio/year.
    @param statesToDistribute - list of indices to all states.
    @param matrix - list of list with costs in mio/year.
    @param threshold - threshold in mio/year.
    @param costSum - initial costs should be zero.
    @param stack - stack for collecting all possible partitions.
    '''
    if args.verbose:
        print 'Iteration:',iterationCounter.next()
    if statesToDistribute:
        state = statesToDistribute.pop(0)
    for i in statesToDistribute:
        cost = matrix[state][i]
        if (costSum + cost) <= threshold:
            newCostSum = costSum + cost
            newStack = [ t for t in stack ]
            newStack.append((state,i,cost))
            newStatesToDistribute = [s for s in statesToDistribute if s != i ]
            if args.verbose:
                print 'tupel: ',(columnNames[state],columnNames[i],cost)
            branchAndBound(newStatesToDistribute,matrix,threshold,newCostSum,newStack)
    if len(stack) == len(matrix)/2:
        #all states are distributed
        print 'Solution',str(c.next())+':'
        sys.stdout.write('{')
        sumC = 0
        for t in stack:
            sumC += t[2]
            cityA = columnNames[t[0]]
            cityB = columnNames[t[1]]
            costs = t[2]
            sys.stdout.write('[('+cityA+','+cityB+'),'+str(costs)+']')
        sys.stdout.write('}, costs: '+str(sumC)+'\n')
stateIndices = range(0,len(matrix))
branchAndBound(stateIndices,matrix,threshold)  
    
    
