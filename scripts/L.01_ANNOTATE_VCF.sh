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
DBSNP=$7
CHROMOSOME=$8

# Annotate the above file with dbSNP AND variant type

END_ANNOTATE_VCF=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R $REF_GENOME \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.vcf.gz" \
--dbsnp $DBSNP \
-L $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.vcf.gz" \
-A GCContent \
-A VariantType \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.annotated.vcf.gz"

END_ANNOTATE_VCF=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT,J.01,ANNOTATE_VCF_$CHROMOSOME,$HOSTNAME,$START_ANNOTATE_VCF,$END_ANNOTATE_VCF \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R $REF_GENOME \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.vcf.gz" \
--dbsnp $DBSNP \
-L $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.vcf.gz" \
-A GCContent \
-A VariantType \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.annotated.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

