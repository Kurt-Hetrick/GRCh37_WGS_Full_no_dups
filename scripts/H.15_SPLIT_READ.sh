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

SAMTOOLS_DIR=$1
LUMPY_DIR=$2

CORE_PATH=$3
PROJECT=$4
SM_TAG=$5

# the default here is to assume that the reads are aligned with bwa_mem, but without the -M argument

START_SPLIT_READ=`date '+%s'`

# Extract the discordant paired-end alignments.

$SAMTOOLS_DIR/samtools view -h \
$CORE_PATH/$PROJECT/BAM/$SM_TAG.bam \
| $LUMPY_DIR/../scripts/extractSplitReads_BwaMem -i stdin \
| $SAMTOOLS_DIR/samtools view -Sb - \
>| $CORE_PATH/$PROJECT/LUMPY/TEMP/$SM_TAG".lumpy.split.reads.bam"

END_SPLIT_READ=`date '+%s'`

# echo $SM_TAG"_"$PROJECT",H.01,SPLIT_READ,"$HOSTNAME","$START_SPLIT_READ","$END_SPLIT_READ\
# >> $CORE_PATH/$PROJECT/$PROJECT".WALL.CLOCK.TIMES.csv"
# 
# echo $SAMTOOLS_DIR/samtools view -h \
# $CORE_PATH/$PROJECT/BAM/$SM_TAG.bam \
# | $LUMPY_DIR/../scripts/extractSplitReads_BwaMem -i stdin \
# | $SAMTOOLS_DIR/samtools view -Sb - \
# \>\| $CORE_PATH/$PROJECT/LUMPY/TEMP/$SM_TAG".lumpy.split.reads.bam" \
# >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
