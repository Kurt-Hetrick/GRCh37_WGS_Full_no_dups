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
CODING_BED=$4
CODING_BED_MT=$5
GATK_KEY=$6

PROJECT=$7
SM_TAG=$8
REF_GENOME=$9

# EXTRACT SAMPLE AND FILTER ON CODING REGIONS

START_EXTRACT_CODING_SNV=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-sn $SM_TAG \
--keepOriginalAC \
-selectType SNP \
-L $CODING_BED \
-L $CODING_BED_MT \
-et NO_ET \
-K $GATK_KEY \
--variant $CORE_PATH/$PROJECT/VCF/SINGLE/WHOLE_GENOME/$SM_TAG".WHOLE.GENOME.vcf.gz" \
-o $CORE_PATH/$PROJECT/SNV/SINGLE/CODING/$SM_TAG".CODING.SNV.vcf.gz"

END_EXTRACT_CODING_SNV=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",Q.01,EXTRACT_EXTRACT_CODING_SNV,"$HOSTNAME","$START_EXTRACT_CODING_SNV","$END_EXTRACT_CODING_SNV \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-sn $SM_TAG \
--keepOriginalAC \
-selectType SNP \
-L $CODING_BED \
-L $CODING_BED_MT \
-et NO_ET \
-K $GATK_KEY \
--variant $CORE_PATH/$PROJECT/VCF/SINGLE/WHOLE_GENOME/$SM_TAG".WHOLE.GENOME.vcf.gz" \
-o $CORE_PATH/$PROJECT/SNV/SINGLE/CODING/$SM_TAG".CODING.SNV.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
