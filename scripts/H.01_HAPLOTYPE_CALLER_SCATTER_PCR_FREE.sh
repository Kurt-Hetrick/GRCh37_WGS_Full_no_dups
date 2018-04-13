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

## Finkbeiner 1 did not limit max alt alleles, which is unfortunate

## -----Haplotype Caller-----

START_HAPLOTYPE_CALLER=`date '+%s'`

# Add ClippingRankSumTest
# Change Coverage to DepthPerSampleHC
# Add StrandBiasBySample

# When updating, add FractionInformativeReads
# when updating remove both confidence cut-offs.

# try to make pcr indel model NONE and optional switch.

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R $REF_GENOME \
--input_file $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-L $CHROMOSOME \
--emitRefConfidence GVCF \
--variant_index_type LINEAR \
--variant_index_parameter 128000 \
-pairHMM VECTOR_LOGLESS_CACHING \
--standard_min_confidence_threshold_for_calling 30 \
--standard_min_confidence_threshold_for_emitting 10 \
--max_alternate_alleles 3 \
--annotation DepthPerSampleHC \
--annotation ClippingRankSumTest \
--annotation MappingQualityRankSumTest \
--annotation ReadPosRankSumTest \
--annotation FisherStrand \
--annotation GCContent \
--annotation AlleleBalanceBySample \
--annotation AlleleBalance \
--annotation QualByDepth \
--annotation StrandBiasBySample \
--annotation MappingQualityZero \
--pcr_indel_model NONE \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".g.vcf.gz"

END_HAPLOTYPE_CALLER=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT,H.01,HAPLOTYPE_CALLER_$CHROMOSOME,$HOSTNAME,$START_HAPLOTYPE_CALLER,$END_HAPLOTYPE_CALLER \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R $REF_GENOME \
--input_file $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-L $CHROMOSOME \
--emitRefConfidence GVCF \
--variant_index_type LINEAR \
--variant_index_parameter 128000 \
-pairHMM VECTOR_LOGLESS_CACHING \
--standard_min_confidence_threshold_for_calling 30 \
--standard_min_confidence_threshold_for_emitting 10 \
--max_alternate_alleles 3 \
--annotation DepthPerSampleHC \
--annotation ClippingRankSumTest \
--annotation MappingQualityRankSumTest \
--annotation ReadPosRankSumTest \
--annotation FisherStrand \
--annotation GCContent \
--annotation AlleleBalanceBySample \
--annotation AlleleBalance \
--annotation QualByDepth \
--annotation StrandBiasBySample \
--annotation MappingQualityZero \
--pcr_indel_model NONE \
-o $CORE_PATH/$PROJECT/TEMP/$SM_TAG"."$CHROMOSOME".g.vcf.gz" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
