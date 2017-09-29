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
DBSNP=$9

## --I am actually going to downsample here, b/c it actually makes more sense to do so.

START_PERFORM_BQSR=`date '+%s'`

$JAVA_1_7/java -jar \
-Xmx46g \
$GATK_DIR/GenomeAnalysisTK.jar \
-T BaseRecalibrator \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_1.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_2.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_3.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_4.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_5.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_6.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_7.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_8.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_9.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_10.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_11.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_12.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_13.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_14.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_15.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_16.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_17.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_18.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_19.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_20.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_21.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_22.realign.bam" \
-knownSites $KNOWN_INDEL_1 \
-knownSites $KNOWN_INDEL_2 \
-knownSites $DBSNP \
--downsample_to_fraction .1 \
-nct 8 \
-o $CORE_PATH/$PROJECT/REPORTS/COUNT_COVARIATES/GATK_REPORT/$SM_TAG"_PERFORM_BQSR.bqsr"

END_PERFORM_BQSR=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",F.01,PERFORM_BQSR,"$HOSTNAME","$START_PERFORM_BQSR","$END_PERFORM_BQSR \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

md5sum $CORE_PATH/$PROJECT/REPORTS/COUNT_COVARIATES/GATK_REPORT/$SM_TAG"_PERFORM_BQSR.bqsr" \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".CIDR.Analysis.MD5.txt"

echo $JAVA_1_7/java -jar \
-Xmx46g \
$GATK_DIR/GenomeAnalysisTK.jar \
-T BaseRecalibrator \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_1.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_2.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_3.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_4.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_5.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_6.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_7.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_8.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_9.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_10.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_11.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_12.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_13.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_14.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_15.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_16.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_17.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_18.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_19.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_20.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_21.realign.bam" \
-I $CORE_PATH/$PROJECT/TEMP/$SM_TAG"_22.realign.bam" \
-knownSites $KNOWN_INDEL_1 \
-knownSites $KNOWN_INDEL_2 \
-knownSites $DBSNP \
--downsample_to_fraction .1 \
-nct 8 \
-o $CORE_PATH/$PROJECT/REPORTS/COUNT_COVARIATES/GATK_REPORT/$SM_TAG"_PERFORM_BQSR.bqsr" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
