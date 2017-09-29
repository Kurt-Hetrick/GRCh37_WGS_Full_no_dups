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

## -----Gather raw whole genome VCF-----

START_GATHER_VCF=`date '+%s'`

$JAVA_1_7/java -cp $GATK_DIR/GenomeAnalysisTK.jar \
org.broadinstitute.gatk.tools.CatVariants \
-R $REF_GENOME \
--assumeSorted \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".1.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".2.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".3.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".4.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".5.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".6.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".7.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".8.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".9.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".10.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".11.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".12.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".13.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".14.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".15.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".16.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".17.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".18.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".19.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".20.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".21.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".22.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".X.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".Y.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".MT.raw.annotated.vcf.gz" \
--outputFile $CORE_PATH/$PROJECT/TEMP/$SM_TAG".raw.vcf.gz"

END_GATHER_VCF=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",M.01,GATHER_VCF,"$HOSTNAME","$START_GATHER_VCF","$END_GATHER_VCF \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -cp $GATK_DIR/GenomeAnalysisTK.jar \
org.broadinstitute.gatk.tools.CatVariants \
-R $REF_GENOME \
--assumeSorted \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".1.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".2.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".3.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".4.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".5.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".6.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".7.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".8.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".9.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".10.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".11.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".12.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".13.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".14.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".15.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".16.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".17.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".18.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".19.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".20.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".21.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".22.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".X.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".Y.raw.annotated.vcf.gz" \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG".MT.raw.annotated.vcf.gz" \
--outputFile $CORE_PATH/$PROJECT/TEMP/$SM_TAG".raw.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
