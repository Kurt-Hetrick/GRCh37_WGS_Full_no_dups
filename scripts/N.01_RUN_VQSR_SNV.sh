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

HAPMAP=$7
OMNI_1KG=$8
HI_CONF_1KG_PHASE1_SNP=$9
DBSNP_129=${10}

module load statgen/R/3.4.0

# Run the SNP only VQSR model

START_RUN_VQSR_SNP=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T VariantRecalibrator \
-R $REF_GENOME \
--input:VCF $CORE_PATH/$PROJECT/TEMP/$SM_TAG".raw.vcf.gz" \
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 $HAPMAP \
-resource:omni,known=false,training=true,truth=true,prior=12.0 $OMNI_1KG \
-resource:1000G,known=false,training=true,truth=false,prior=10.0 $HI_CONF_1KG_PHASE1_SNP \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DBSNP_129 \
-mode SNP \
-an QD \
-an ReadPosRankSum \
-an FS \
-an DP \
-an SOR \
-tranche 100.0 \
-tranche 99.9 \
-tranche 99.8 \
-tranche 99.7 \
-tranche 99.6 \
-tranche 99.5 \
-tranche 99.4 \
-tranche 99.3 \
-tranche 99.2 \
-tranche 99.1 \
-tranche 99.0 \
-tranche 98.0 \
-tranche 97.0 \
-tranche 96.0 \
-tranche 95.0 \
-tranche 90.0 \
-recalFile $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/$SM_TAG".HC.SNV.recal" \
-tranchesFile $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/$SM_TAG".HC.SNV.tranches" \
-rscriptFile $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/$SM_TAG".HC.SNV.R"

END_RUN_VQSR_SNP=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",N.01,RUN_VQSR_SNP,"$HOSTNAME","$START_RUN_VQSR_SNP","$END_RUN_VQSR_SNP \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T VariantRecalibrator \
-R $REF_GENOME \
--input:VCF $CORE_PATH/$PROJECT/TEMP/$SM_TAG".raw.vcf.gz" \
-resource:hapmap,known=false,training=true,truth=true,prior=15.0 $HAPMAP \
-resource:omni,known=false,training=true,truth=true,prior=12.0 $OMNI_1KG \
-resource:1000G,known=false,training=true,truth=false,prior=10.0 $HI_CONF_1KG_PHASE1_SNP \
-resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $DBSNP_129 \
-mode SNP \
-an QD \
-an MQRankSum \
-an ReadPosRankSum \
-an FS \
-an DP \
-an SOR \
-tranche 100.0 \
-tranche 99.9 \
-tranche 99.8 \
-tranche 99.7 \
-tranche 99.6 \
-tranche 99.5 \
-tranche 99.4 \
-tranche 99.3 \
-tranche 99.2 \
-tranche 99.1 \
-tranche 99.0 \
-tranche 98.0 \
-tranche 97.0 \
-tranche 96.0 \
-tranche 95.0 \
-tranche 90.0 \
-recalFile $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/$SM_TAG".HC.SNV.recal" \
-tranchesFile $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/$SM_TAG".HC.SNV.tranches" \
-rscriptFile $CORE_PATH/$PROJECT/SNV/SINGLE/WHOLE_GENOME/$SM_TAG".HC.SNV.R" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
