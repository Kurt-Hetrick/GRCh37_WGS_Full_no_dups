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
GAP_BED=$4
GATK_KEY=$5

PROJECT=$6
SM_TAG=$7
REF_GENOME=$8

### --Depth of Coverage On Bait--

START_AUTO_CVG=`date '+%s'`

$JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-XL X \
-XL Y \
-XL MT \
-XL GL000207.1 \
-XL GL000226.1 \
-XL GL000229.1 \
-XL GL000231.1 \
-XL GL000210.1 \
-XL GL000239.1 \
-XL GL000235.1 \
-XL GL000201.1 \
-XL GL000247.1 \
-XL GL000245.1 \
-XL GL000197.1 \
-XL GL000203.1 \
-XL GL000246.1 \
-XL GL000249.1 \
-XL GL000196.1 \
-XL GL000248.1 \
-XL GL000244.1 \
-XL GL000238.1 \
-XL GL000202.1 \
-XL GL000234.1 \
-XL GL000232.1 \
-XL GL000206.1 \
-XL GL000240.1 \
-XL GL000236.1 \
-XL GL000241.1 \
-XL GL000243.1 \
-XL GL000242.1 \
-XL GL000230.1 \
-XL GL000237.1 \
-XL GL000233.1 \
-XL GL000204.1 \
-XL GL000198.1 \
-XL GL000208.1 \
-XL GL000191.1 \
-XL GL000227.1 \
-XL GL000228.1 \
-XL GL000214.1 \
-XL GL000221.1 \
-XL GL000209.1 \
-XL GL000218.1 \
-XL GL000220.1 \
-XL GL000213.1 \
-XL GL000211.1 \
-XL GL000199.1 \
-XL GL000217.1 \
-XL GL000216.1 \
-XL GL000215.1 \
-XL GL000205.1 \
-XL GL000219.1 \
-XL GL000224.1 \
-XL GL000223.1 \
-XL GL000195.1 \
-XL GL000212.1 \
-XL GL000222.1 \
-XL GL000200.1 \
-XL GL000193.1 \
-XL GL000194.1 \
-XL GL000225.1 \
-XL GL000192.1 \
-XL NC_007605 \
-XL hs37d5 \
-XL $GAP_BED \
-mmq 20 \
-mbq 10 \
--outputFormat csv \
-omitBaseOutput \
-omitIntervals \
--omitLocusTable \
-o $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.whole_genome" \
-et NO_ET \
-K $GATK_KEY \
-ct 5 \
-ct 10 \
-ct 15 \
-ct 20 \
-nt 4

END_AUTO_CVG=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT"_BAM_REPORTS,Z.01,AUTO_CVG,"$HOSTNAME","$START_AUTO_CVG","$END_AUTO_CVG \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $JAVA_1_7/java -jar $GATK_DIR/GenomeAnalysisTK.jar \
-T DepthOfCoverage \
-R $REF_GENOME \
-I $CORE_PATH/$PROJECT/BAM/$SM_TAG".bam" \
-XL X \
-XL Y \
-XL MT \
-XL GL000207.1 \
-XL GL000226.1 \
-XL GL000229.1 \
-XL GL000231.1 \
-XL GL000210.1 \
-XL GL000239.1 \
-XL GL000235.1 \
-XL GL000201.1 \
-XL GL000247.1 \
-XL GL000245.1 \
-XL GL000197.1 \
-XL GL000203.1 \
-XL GL000246.1 \
-XL GL000249.1 \
-XL GL000196.1 \
-XL GL000248.1 \
-XL GL000244.1 \
-XL GL000238.1 \
-XL GL000202.1 \
-XL GL000234.1 \
-XL GL000232.1 \
-XL GL000206.1 \
-XL GL000240.1 \
-XL GL000236.1 \
-XL GL000241.1 \
-XL GL000243.1 \
-XL GL000242.1 \
-XL GL000230.1 \
-XL GL000237.1 \
-XL GL000233.1 \
-XL GL000204.1 \
-XL GL000198.1 \
-XL GL000208.1 \
-XL GL000191.1 \
-XL GL000227.1 \
-XL GL000228.1 \
-XL GL000214.1 \
-XL GL000221.1 \
-XL GL000209.1 \
-XL GL000218.1 \
-XL GL000220.1 \
-XL GL000213.1 \
-XL GL000211.1 \
-XL GL000199.1 \
-XL GL000217.1 \
-XL GL000216.1 \
-XL GL000215.1 \
-XL GL000205.1 \
-XL GL000219.1 \
-XL GL000224.1 \
-XL GL000223.1 \
-XL GL000195.1 \
-XL GL000212.1 \
-XL GL000222.1 \
-XL GL000200.1 \
-XL GL000193.1 \
-XL GL000194.1 \
-XL GL000225.1 \
-XL GL000192.1 \
-XL NC_007605 \
-XL hs37d5 \
-XL $GAP_BED \
-mmq 20 \
-mbq 10 \
--outputFormat csv \
-omitBaseOutput \
-omitIntervals \
--omitLocusTable \
-o $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.whole_genome" \
-et NO_ET \
-K $GATK_KEY \
-ct 5 \
-ct 10 \
-ct 15 \
-ct 20 \
-nt 4 \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.whole_genome.sample_statistics" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.whole_genome.sample_statistics.csv"

mv -v $CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.whole_genome.sample_summary" \
$CORE_PATH/$PROJECT/REPORTS/DEPTH_OF_COVERAGE/DEPTH_SUMMARY/$SM_TAG".autosomal.whole_genome.sample_summary.csv"
