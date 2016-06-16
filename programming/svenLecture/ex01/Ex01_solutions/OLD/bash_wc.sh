#!/bin/bash

# counts words of input file and prints it by frequency and in alphabetical order

cat $1 | tr [A-Z] [a-z] | sed -e 's/[^[:alpha:]]/ /g' -e 's/ /\n/g' | sort | uniq -c | sort -nr | awk 'NF>1 { print }'
