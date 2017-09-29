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
DBSNP_129=$4
GATK_KEY=$5

PROJECT=$6
SM_TAG=$7
REF_GENOME=$8

# PASSING SNVS IN CODING REGIONS THAT ARE IN DBSNP 129

START_EXTRACT_CODING_KNOWN

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-et NO_ET \
-K $GATK_KEY \
--variant $CORE_PATH/$PROJECT/SNV/SINGLE/CODING/PASS/$SM_TAG".CODING.SNV.PASS.vcf.gz" \
--concordance $DBSNP_129 \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".QC.Coding.Known.TiTv.vcf.gz"

END_EXTRACT_CODING_KNOWN=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",R.01,EXTRACT_CODING_KNOWN,"$HOSTNAME","$START_EXTRACT_CODING_KNOWN","$END_EXTRACT_CODING_KNOWN \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-et NO_ET \
-K $GATK_KEY \
--variant $CORE_PATH/$PROJECT/SNV/SINGLE/CODING/PASS/$SM_TAG".CODING.SNV.PASS.vcf.gz" \
--concordance $DBSNP_129 \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".QC.Coding.Known.TiTv.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
