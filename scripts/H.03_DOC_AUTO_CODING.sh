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
GATK_KEY=$5

PROJECT=$6
SM_TAG=$7
REF_GENOME=$8

### --Remove X,Y,MT from the UCSC exons bed file

START_AUTO_CODING_CVG=`date '+%s'`

awk '{FS=" "} $1!~/[A-Z]/ {print $0}' $CODING_BED \
>| $CORE_PATH/$PROJECT/TEMP/$SM_TAG".AUTO.CODING.bed"

### --Depth of Coverage AUTOSOMAL UCSC CODINGS--

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-L $CORE_PATH/$PROJECT/TEMP/$SM_TAG".AUTO.CODING.bed" \
-mmq 20 \
-mbq 10 \
--outputFormat csv \
-omitBaseOutput \
-omitIntervals \
--omitLocusTable \
-o $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon" \
-et NO_ET \
-K $GATK_KEY \
-ct 5 \
-ct 10 \
-ct 15 \
-ct 20 \
-nt 4

END_AUTO_CODING_CVG=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,AUTO_CODING_CVG,"$HOSTNAME","$START_AUTO_CODING_CVG","$END_AUTO_CODING_CVG \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-L $CORE_PATH/$PROJECT/TEMP/$SM_TAG".AUTO.CODING.bed" \
-mmq 20 \
-mbq 10 \
--outputFormat csv \
-omitBaseOutput \
-omitIntervals \
--omitLocusTable \
-o $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon" \
-et NO_ET \
-K $GATK_KEY \
-ct 5 \
-ct 10 \
-ct 15 \
-ct 20 \
-nt 4 \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon.sample_statistics" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon.sample_statistics.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon.sample_summary" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.exon.sample_summary.csv"
