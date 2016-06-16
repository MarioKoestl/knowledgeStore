#qstat -q \*  show all on this pc
#qstat -j command id   = show details of current job
#qdel -u username delete all jobs from user
#qsub script name   = send script to grid engine


#c_highmem.q = high memory
# -l = exclude this node
# SGE_TASK_ID is runningindex

#$1 = first parameter of shell script
#$2 = second one..


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

# create and change directory on sge script, -p = do nothing if already existing and will create parent directories if needed
mkdir -p ${TMP_DIR}/${SGE_TASK_ID}
cd ${TMP_DIR}/${SGE_TASK_ID}


# wait some time (up to 1s), to allow scripts to open the inputFile 
rand=`echo "$RANDOM % 100" | bc`
rand2=`echo "$rand / 100." | bc -l`
sleep ${rand2}s

#copy input data to local sge folder, which is .
#if [ ! -e ./GridEngineScript ] ; then
cp ${INPUT_FILE} .
#fi

#copy the programm to local sge folder
if [ ! -e ./kinwalker ] ; then
  cp "/home/mescalin/bioinf/Mario/Programs/Kinwalker/kinwalker" .
fi

line=`awk "NR==${SGE_TASK_ID}" ./GridEngineScript`   #awk cuts the currentRow (TaskId=row number) from the Echo Script.  NR==2 use the second line of the file
eval $line	# eval instead of echo because, inside the $line variable is an 'echo' function

# clean up
rm -f ./GridEngineScript




