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
TRANSCRIPT_BED=$4
TRANSCRIPT_BED_MT=$5
GENE_LIST=$6
GATK_KEY=$7

PROJECT=$8
SM_TAG=$9
REF_GENOME=${10}

### --Depth of Coverage On TRANSCRIPT--

START_DOC_TRANSCRIPT=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R $REF_GENOME \
-geneList:REFSEQ $GENE_LIST \
-I $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-L $TRANSCRIPT_BED \
-L $TRANSCRIPT_BED_MT \
-mmq 20 \
-mbq 10 \
--outputFormat csv \
-omitBaseOutput \
-o $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript" \
-et NO_ET \
-K $GATK_KEY \
-ct 5 \
-ct 10 \
-ct 15 \
-ct 20

END_DOC_TRANSCRIPT=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,DOC_TRANSCRIPT,"$HOSTNAME","$START_DOC_TRANSCRIPT","$END_DOC_TRANSCRIPT \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R $REF_GENOME \
-geneList:REFSEQ $GENE_LIST \
-I $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-L $TRANSCRIPT_BED \
-L $TRANSCRIPT_BED_MT \
-mmq 20 \
-mbq 10 \
--outputFormat csv \
-omitBaseOutput \
-o $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript" \
-et NO_ET \
-K $GATK_KEY \
-ct 5 \
-ct 10 \
-ct 15 \
-ct 20 \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_cumulative_coverage_counts" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_cumulative_coverage_counts.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_cumulative_coverage_proportions" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_cumulative_coverage_proportions.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_gene_summary" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_gene_summary.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_interval_statistics" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_interval_statistics.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_interval_summary" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_interval_summary.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_statistics" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_statistics.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_summary" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/TRANSCRIPT_COVERAGE/$SM_TAG".ucsc.transcript.sample_summary.csv"
