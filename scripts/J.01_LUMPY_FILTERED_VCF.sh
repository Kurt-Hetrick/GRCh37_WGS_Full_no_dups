# ---qsub parameter settings---
# --these can be overrode at qsub invocation--

# tell sge to execute in bash
#$ -S /bin/bash 

# tell sge to submit any of these queue when available
#$ -q prod.q,rnd.q,test.q,bigdata.q

# tell sge that you are in the users current working directory
#$ -cwd

# tell sge to export the users environment variables
#$ -V

# tell sge to submit at this priority setting
#$ -p -450

# tell sge to output both stderr and stdout to the same file
#$ -j y

# export all variables, useful to find out what compute node the program was executed on
# redirecting stderr/stdout to file as a log.

set

echo

LUMPY_DIR=$1

CORE_PATH=$2
PROJECT=$3
SM_TAG=$4

# Grab the Median Insert size from insert size metrics

INSERT_SIZE_MED=`awk 'NR==8 {print $1}' $CORE_PATH/$PROJECT/REPORTS/INSERT_SIZE/METRICS/$SM_TAG"_insert_size_metrics.txt"`

echo MEDIAN INSERT SIZE IS $INSERT_SIZE_MED

INSERT_SIZE_STD=`awk 'NR==8 {print $2}' $CORE_PATH/$PROJECT/REPORTS/INSERT_SIZE/METRICS/$SM_TAG"_insert_size_metrics.txt"`

echo MEDIAN ABSOLUTE DEVIATION IS $INSERT_SIZE_STD

# Grab the read length from Alignment summary metrics

READ_LENGTH=`awk 'NR==10 {print $16}' $CORE_PATH/$PROJECT/REPORTS/ALIGNMENT_SUMMARY/$SM_TAG"_alignment_summary_metrics.txt"`

echo READ LENGTH IS $READ_LENGTH

START_LUMPY_FILTERED_VCF=`date '+%s'`

$LUMPY_DIR/lumpy \
-mw 4 \
-tt 0 \
-e \
-P \
-x $CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG.exclude.bed \
-pe \
id:$SM_TAG,\
bam_file:$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.bam",\
histo_file:$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.hist.txt",\
mean:$INSERT_SIZE_MED,\
stdev:$INSERT_SIZE_STD,\
read_length:$READ_LENGTH,\
min_non_overlap:101,\
discordant_z:5,\
back_distance:10,\
weight:1,\
min_mapping_threshold:20 \
-sr \
id:$SM_TAG,\
bam_file:$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.split.reads.sort.bam"\
back_distance:10,\
weight:1,\
min_mapping_threshold:20 \
>| $CORE_PATH/$PROJECT/LUMPY/VCF/$SM_TAG.LUMPY.FILTERED.vcf

END_LUMPY_FILTERED_VCF=`date '+%s'`

echo $SM_TAG"_"$PROJECT",J.01,LUMPY_FILTERED_VCF,"$HOSTNAME","$START_LUMPY_FILTERED_VCF","$END_LUMPY_FILTERED_VCF\
>> $CORE_PATH/$PROJECT/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $LUMPY_DIR/lumpy \
-mw 4 \
-tt 0 \
-e \
-P \
-x $CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG.exclude.bed \
-pe \
id:$SM_TAG,\
bam_file:$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.bam",\
histo_file:$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.hist.txt",\
mean:$INSERT_SIZE_MED,\
stdev:$INSERT_SIZE_STD,\
read_length:$READ_LENGTH,\
min_non_overlap:101,\
discordant_z:5,\
back_distance:10,\
weight:1,\
min_mapping_threshold:20 \
-sr \
id:$SM_TAG,\
bam_file:$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.split.reads.sort.bam",\
back_distance:10,\
weight:1,\
min_mapping_threshold:20 \
\>\| $CORE_PATH/$PROJECT/LUMPY/VCF/$SM_TAG.LUMPY.FILTERED.vcf \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
