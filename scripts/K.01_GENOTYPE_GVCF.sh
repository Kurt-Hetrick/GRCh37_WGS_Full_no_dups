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
CHROMOSOME=$7

# Now creating a normal VCF file

END_GENOTYPE_GVCF=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T GenotypeGVCFs \
-R $REF_GENOME \
--standard_min_confidence_threshold_for_calling 30 \
--standard_min_confidence_threshold_for_emitting 10 \
--annotateNDA \
--annotation StrandBiasBySample \
--annotation QualByDepth \
--annotation StrandOddsRatio \
--annotation FisherStrand \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".g.vcf.gz" \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".raw.vcf.gz"

END_GENOTYPE_GVCF=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT,I.01,GENOTYPE_GVCF_$CHROMOSOME,$HOSTNAME,$START_GENOTYPE_GVCF,$END_GENOTYPE_GVCF \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T GenotypeGVCFs \
-R $REF_GENOME \
--standard_min_confidence_threshold_for_calling 30 \
--standard_min_confidence_threshold_for_emitting 10 \
--annotateNDA \
--annotation StrandBiasBySample \
--annotation QualByDepth \
--annotation StrandOddsRatio \
--annotation FisherStrand \
--variant $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".g.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
