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
GATK_DIR=$2
CORE_PATH=$3

PROJECT=$4
SM_TAG=$5
REF_GENOME=$6
KNOWN_INDEL_1=$7
KNOWN_INDEL_2=$8
CHROMOSOME=$9

## --Local realignment turn off downsampling

START_INDEL_REALIGNER=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T IndelRealigner \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG".original.bam" \
-R $REF_GENOME \
-L $CHROMOSOME \
-known $KNOWN_INDEL_1 \
-known $KNOWN_INDEL_2 \
-targetIntervals $CORE_PATH/$PROJECT/REPORTS/LOCAL_REALIGNMENT_INTERVALS/$SM_TAG"_"$CHROMOSOME"_LOCAL_REALIGNMENT_INTERVALS.intervals" \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_"$CHROMOSOME".realign.bam"

END_INDEL_REALIGNER=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",E.01,INDEL_REALIGNER,"$HOSTNAME","$START_INDEL_REALIGNER","$END_INDEL_REALIGNER \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T IndelRealigner \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG".original.bam" \
-R $REF_GENOME \
-L $CHROMOSOME \
-known $KNOWN_INDEL_1 \
-known $KNOWN_INDEL_2 \
-targetIntervals $CORE_PATH/$PROJECT/REPORTS/LOCAL_REALIGNMENT_INTERVALS/$SM_TAG"_LOCAL_REALIGNMENT_INTERVALS.intervals" \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".realign.bam" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
