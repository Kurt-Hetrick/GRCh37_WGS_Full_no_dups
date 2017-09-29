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
PICARD_DIR=$2
CORE_PATH=$3

PROJECT=$4
SM_TAG=$5
REF_GENOME=$6

## --Mean Quality By Cycle--

START_MEAN_QUALITY_BY_CYCLE=`date '+%s'`

$JAVA_1_7/java -jar $PICARD_DIR/MeanQualityByCycle.jar \
INPUT=$CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
OUTPUT=$CORE_PATH/$PROJECT/REPORTS/MEAN_QUALITY_BY_CYCLE/METRICS/$SM_TAG"_mean_quality_by_cycle.txt" \
CHART=$CORE_PATH/$PROJECT/REPORTS/MEAN_QUALITY_BY_CYCLE/PDF/$SM_TAG"_mean_quality_by_cycle_chart.pdf" \
R=$REF_GENOME \
VALIDATION_STRINGENCY=SILENT

END_MEAN_QUALITY_BY_CYCLE=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,MEAN_QUALITY_BY_CYCLE,"$HOSTNAME","$START_MEAN_QUALITY_BY_CYCLE","$END_MEAN_QUALITY_BY_CYCLE \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $PICARD_DIR/MeanQualityByCycle.jar \
INPUT=$CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
OUTPUT=$CORE_PATH/$PROJECT/REPORTS/MEAN_QUALITY_BY_CYCLE/METRICS/$SM_TAG"_mean_quality_by_cycle.txt" \
CHART=$CORE_PATH/$PROJECT/REPORTS/MEAN_QUALITY_BY_CYCLE/PDF/$SM_TAG"_mean_quality_by_cycle_chart.pdf" \
R=$REF_GENOME \
VALIDATION_STRINGENCY=SILENT \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
