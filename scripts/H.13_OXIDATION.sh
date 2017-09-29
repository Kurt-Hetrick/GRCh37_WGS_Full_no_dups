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

SAMTOOLS_DIR=$1
JAVA_1_7=$2
PICARD_DIR2=$3
CORE_PATH=$4

PROJECT=$5
SM_TAG=$6
REF_GENOME=$7
DBSNP=$8

# Create CollectOxoGMetrics metrics bed files

START_OXIDATION=`date '+%s'`

($SAMTOOLS_DIR/samtools view -H $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
| grep "^@SQ" ; echo -e 1"\t"1"\t"200000000"\t"+"\t"FOO) \
>| $CORE_PATH/$PROJECT/TEMP/$SM_TAG".CHR1.oxidation.picard.bed"

## --Collect metrics quantifying the CpCG -> CpCA error rate from the provided SAM/BAM--

$JAVA_1_7/java -jar $PICARD_DIR2/picard.jar \
CollectOxoGMetrics \
INPUT=$CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
OUTPUT=$CORE_PATH/$PROJECT/REPORTS/OXIDATION/$SM_TAG"_oxidation.txt" \
R=$REF_GENOME \
INTERVALS=$CORE_PATH/$PROJECT/TEMP/$SM_TAG".CHR1.oxidation.picard.bed" \
DB_SNP=$DBSNP \
MINIMUM_QUALITY_SCORE=10 \
MINIMUM_MAPPING_QUALITY=20 \
VALIDATION_STRINGENCY=SILENT

END_OXIDATION=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,OXIDATION,"$HOSTNAME","$START_OXIDATION","$END_OXIDATION \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $PICARD_DIR2/picard.jar \
CollectOxoGMetrics \
INPUT=$CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
OUTPUT=$CORE_PATH/$PROJECT/REPORTS/OXIDATION/$SM_TAG"_oxidation.txt" \
R=$REF_GENOME \
INTERVALS=$CORE_PATH/$PROJECT/TEMP/$SM_TAG".CHR1.oxidation.picard.bed" \
DB_SNP=$DBSNP \
MINIMUM_QUALITY_SCORE=10 \
MINIMUM_MAPPING_QUALITY=20 \
VALIDATION_STRINGENCY=SILENT \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
