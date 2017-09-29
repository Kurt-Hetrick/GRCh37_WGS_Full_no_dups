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

# TI/TV WHOLE GENOME NOVEL

START_EXTRACT_WG_NOVEL

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-et NO_ET \
-K $GATK_KEY \
--variant $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/PASS/$SM_TAG".WHOLE.GENOME.SNV.PASS.vcf.gz" \
--discordance $DBSNP_129 \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".QC.WG.Novel.TiTv.vcf.gz"

END_EXTRACT_WG_NOVEL=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",R.01,EXTRACT_WG_NOVEL,"$HOSTNAME","$START_EXTRACT_WG_NOVEL","$END_EXTRACT_WG_NOVEL \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T SelectVariants \
-R $REF_GENOME \
-et NO_ET \
-K $GATK_KEY \
--variant $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/PASS/$SM_TAG".WHOLE.GENOME.SNV.PASS.vcf.gz" \
--discordance $DBSNP_129 \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG".QC.WG.Novel.TiTv.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
