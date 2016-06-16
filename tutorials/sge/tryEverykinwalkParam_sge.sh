#!/bin/bash

#$ -t 1-300
#$ -q c_highmem.q
#$ -e /home/mescalin/bioinf/Mario/error.sge/
#$ -o /home/mescalin/bioinf/Mario/output.sge/
#$ -l h=!tc04

INPUT_FILE="/home/mescalin/bioinf/Mario/DATA/input/ges_Scripts/GridEngineScript"
	

# locate the working directory on the sge
if [ -d /scratch/gridengine/${JOB_ID}.${SGE_TASK_ID}.c_highmem.q/ ] ; then
  TMP_DIR="/scratch/gridengine/${JOB_ID}.${SGE_TASK_ID}.c_highmem.q/"
elif [ -d /scratch/sge/${JOB_ID}.${SGE_TASK_ID}.c_highmem.q/ ] ; then
  TMP_DIR="/scratch/sge/${JOB_ID}.${SGE_TASK_ID}.c_highmem.q/"
else
  TMP_DIR=/tmp/
fi

# change directory
mkdir -p ${TMP_DIR}/${SGE_TASK_ID}
cd ${TMP_DIR}/${SGE_TASK_ID}


# wait some time (up to 1s), to allow scripts to open the inputFile 
rand=`echo "$RANDOM % 100" | bc`
rand2=`echo "$rand / 100." | bc -l`
sleep ${rand2}s

#copy inputData to local sge files, which is .
#if [ ! -e ./GridEngineScript ] ; then
cp ${INPUT_FILE} .
#fi

#copy the programm to lacal sge folder
if [ ! -e ./kinwalker ] ; then
  cp "/home/mescalin/bioinf/Mario/Programs/Kinwalker/kinwalker" .
fi

line=`awk "NR==${SGE_TASK_ID}" ./GridEngineScript`   #awk cuts the currentRow+ TaskId from the Echo Script
eval $line	# eval instead of echo because, inside the $line variable is an 'echo' function

# clean up
rm -f ./GridEngineScript



