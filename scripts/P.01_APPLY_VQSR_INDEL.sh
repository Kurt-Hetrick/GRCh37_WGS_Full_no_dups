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

START_APPLY_VQSR_INDEL=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T ApplyRecalibration \
-R $REF_GENOME \
--input:VCF $CORE_PATH/$PROJECT/TEMP/$SM_TAG".SNV.VQSR.vcf.gz" \
--ts_filter_level 99.0 \
-recalFile $CORE_PATH/$PROJECT/INDEL/SINGLE/WHOLE_GENOME/$SM_TAG".HC.INDEL.recal" \
-tranchesFile $CORE_PATH/$PROJECT/INDEL/SINGLE/WHOLE_GENOME/$SM_TAG".HC.INDEL.tranches" \
-mode INDEL \
-o $CORE_PATH/$PROJECT/VCF/SINGLE/WHOLE_GENOME/$SM_TAG".WHOLE.GENOME.vcf.gz"

START_APPLY_VQSR_INDEL=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",P.01,APPLY_VQSR_INDEL,"$HOSTNAME","$START_APPLY_VQSR_INDEL","$END_APPLY_VQSR_INDEL \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T ApplyRecalibration \
-R $REF_GENOME \
--input:VCF $CORE_PATH/$PROJECT/TEMP/$SM_TAG".SNV.VQSR.vcf.gz" \
--ts_filter_level 99.0 \
-recalFile $CORE_PATH/$PROJECT/INDEL/SINGLE/WHOLE_GENOME/$SM_TAG".HC.INDEL.recal" \
-tranchesFile $CORE_PATH/$PROJECT/INDEL/SINGLE/WHOLE_GENOME/$SM_TAG".HC.INDEL.tranches" \
-mode INDEL \
-o $CORE_PATH/$PROJECT/VCF/SINGLE/WHOLE_GENOME/$SM_TAG".WHOLE.GENOME.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
