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
VERIFY_DIR=$2
CORE_PATH=$3
VERIFY_VCF=$4

PROJECT=$5
SM_TAG=$6

## --Running verifyBamID--

START_VERIFYBAMID=`date '+%s'`

$VERIFY_DIR/verifyBamID \
--bam $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
--vcf $VERIFY_VCF \
--out $CORE_PATH/$PROJECT/REPORTS/VERIFY_BAM_ID/$SM_TAG \
--precise \
--verbose \
--maxDepth 200

END_VERIFYBAMID=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,VERIFYBAMID,"$HOSTNAME","$START_VERIFYBAMID","$END_VERIFYBAMID \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $VERIFY_DIR/verifyBamID \
--bam $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
--vcf $VERIFY_VCF \
--out $CORE_PATH/$PROJECT/REPORTS/VERIFY_BAM_ID/$SM_TAG \
--precise \
--verbose \
--maxDepth 200 \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
