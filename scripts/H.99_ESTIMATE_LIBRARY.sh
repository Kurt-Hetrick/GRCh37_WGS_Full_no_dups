# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash

# tell sge to submit any of these queue when available
#$ -q rnd.q,prod.q,test.q,bigdata.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -1020

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

set

echo

JAVA_1_7=$1
PICARD_DIR2=$2
CORE_PATH=$3

PROJECT=$4
SM_TAG=$5

## --Estimate Library Complexity from bam file

START_ESTIMATE_LIBRARY=`date '+%s'`

$JAVA_1_7/java -jar $PICARD_DIR2/picard.jar \
EstimateLibraryComplexity \
INPUT=$CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
OUTPUT=$CORE_PATH/$PROJECT/REPORTS/DUPLICATES/$SM_TAG"_MARK_DUPLICATES.txt" \
VALIDATION_STRINGENCY=SILENT

END_ESTIMATE_LIBRARY=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,ESTIMATE_LIBRARY,"$HOSTNAME","$START_ESTIMATE_LIBRARY","$END_ESTIMATE_LIBRARY \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $PICARD_DIR2/picard.jar \
EstimateLibraryComplexity \
INPUT=$CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
OUTPUT=$CORE_PATH/$PROJECT/REPORTS/DUPLICATES/$SM_TAG"_MARK_DUPLICATES.txt" \
VALIDATION_STRINGENCY=SILENT \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
