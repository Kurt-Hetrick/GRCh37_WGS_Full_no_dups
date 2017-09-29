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

## --Realigner Target Creator, turn off downsampling

START_PRINT_JUNK_ALIGNMENTS=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T PrintReads \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG".original.bam" \
-L GL000207.1 \
-L GL000226.1 \
-L GL000229.1 \
-L GL000231.1 \
-L GL000210.1 \
-L GL000239.1 \
-L GL000235.1 \
-L GL000201.1 \
-L GL000247.1 \
-L GL000245.1 \
-L GL000197.1 \
-L GL000203.1 \
-L GL000246.1 \
-L GL000249.1 \
-L GL000196.1 \
-L GL000248.1 \
-L GL000244.1 \
-L GL000238.1 \
-L GL000202.1 \
-L GL000234.1 \
-L GL000232.1 \
-L GL000206.1 \
-L GL000240.1 \
-L GL000236.1 \
-L GL000241.1 \
-L GL000243.1 \
-L GL000242.1 \
-L GL000230.1 \
-L GL000237.1 \
-L GL000233.1 \
-L GL000204.1 \
-L GL000198.1 \
-L GL000208.1 \
-L GL000191.1 \
-L GL000227.1 \
-L GL000228.1 \
-L GL000214.1 \
-L GL000221.1 \
-L GL000209.1 \
-L GL000218.1 \
-L GL000220.1 \
-L GL000213.1 \
-L GL000211.1 \
-L GL000199.1 \
-L GL000217.1 \
-L GL000216.1 \
-L GL000215.1 \
-L GL000205.1 \
-L GL000219.1 \
-L GL000224.1 \
-L GL000223.1 \
-L GL000195.1 \
-L GL000212.1 \
-L GL000222.1 \
-L GL000200.1 \
-L GL000193.1 \
-L GL000194.1 \
-L GL000225.1 \
-L GL000192.1 \
-L NC_007605 \
-L hs37d5 \
-L unmapped \
-nct 8 \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".JUNK_ALIGNMENTS.bam"

END_PRINT_JUNK_ALIGNMENTS=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",D.01,JUNK_ALIGNMENTS,"$HOSTNAME","$START_PRINT_JUNK_ALIGNMENTS","$END_PRINT_JUNK_ALIGNMENTS \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T PrintReads \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG".original.bam" \
-L GL000207.1 \
-L GL000226.1 \
-L GL000229.1 \
-L GL000231.1 \
-L GL000210.1 \
-L GL000239.1 \
-L GL000235.1 \
-L GL000201.1 \
-L GL000247.1 \
-L GL000245.1 \
-L GL000197.1 \
-L GL000203.1 \
-L GL000246.1 \
-L GL000249.1 \
-L GL000196.1 \
-L GL000248.1 \
-L GL000244.1 \
-L GL000238.1 \
-L GL000202.1 \
-L GL000234.1 \
-L GL000232.1 \
-L GL000206.1 \
-L GL000240.1 \
-L GL000236.1 \
-L GL000241.1 \
-L GL000243.1 \
-L GL000242.1 \
-L GL000230.1 \
-L GL000237.1 \
-L GL000233.1 \
-L GL000204.1 \
-L GL000198.1 \
-L GL000208.1 \
-L GL000191.1 \
-L GL000227.1 \
-L GL000228.1 \
-L GL000214.1 \
-L GL000221.1 \
-L GL000209.1 \
-L GL000218.1 \
-L GL000220.1 \
-L GL000213.1 \
-L GL000211.1 \
-L GL000199.1 \
-L GL000217.1 \
-L GL000216.1 \
-L GL000215.1 \
-L GL000205.1 \
-L GL000219.1 \
-L GL000224.1 \
-L GL000223.1 \
-L GL000195.1 \
-L GL000212.1 \
-L GL000222.1 \
-L GL000200.1 \
-L GL000193.1 \
-L GL000194.1 \
-L GL000225.1 \
-L GL000192.1 \
-L NC_007605 \
-L hs37d5 \
-L unmapped \
-nct 8 \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".JUNK_ALIGNMENTS.bam" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
