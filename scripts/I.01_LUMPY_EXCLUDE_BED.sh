# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q prod.q,rnd.q,test.q,bigdata.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -450

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

set

echo

PYTHON_EXE=`which python`

echo PYTHON BEING USED IS $PYTHON_EXE

echo

echo LD_LIBRARY_PATH IS $LD_LIBRARY_PATH

echo

echo PATH is $PATH

echo

LUMPY_DIR=$1

CORE_PATH=$2
PROJECT=$3
SM_TAG=$4

# grab the median coverage depth

MEDIAN_DEPTH=`awk 'BEGIN {FS=","} NR==2 {print $5}' $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon.sample_summary.csv"`

# CUT-OFF IS MEDIAN DEPTH TIMES 10

CUTOFF=`echo "$MEDIAN_DEPTH * 10" | bc`

# GENERATE REGIONS WITH 10 TIMES THE MEDIAN DEPTH

START_EXCLUSION_LIST=`date '+%s'`

python $LUMPY_DIR/../scripts/get_exclude_regions.py \
$CUTOFF \
$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG.exclude.bed \
$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.bam" \
$CORE_PATH/$PROJECT/LUMPY/TEMP/$SM_TAG".lumpy.split.reads.bam"

END_EXCLUSION_LIST=`date '+%s'`

echo $SM_TAG"_"$PROJECT",J.01_EXCLUSION_LIST,"$HOSTNAME","$START_EXCLUSION_LIST","$END_EXCLUSION_LIST\
>> $CORE_PATH/$PROJECT/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $LUMPY_DIR/../scripts/get_exclude_regions.py \
$CUTOFF \
$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG.exclude.bed \
$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.bam" \
$CORE_PATH/$PROJECT/LUMPY/TEMP/$SM_TAG".lumpy.split.reads.bam" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
