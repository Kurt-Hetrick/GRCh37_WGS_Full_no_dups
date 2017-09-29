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

# Grab the read length from Alignment summary metrics

READ_LENGTH=`awk 'NR==10 {print $16}' $CORE_PATH/$PROJECT/REPORTS/ALIGNMENT_SUMMARY/$SM_TAG"_alignment_summary_metrics.txt"`

echo READ LENGTH IS $READ_LENGTH

# Generate the breakpoint probability histogram

START_HIST=`date '+%s'`

$SAMTOOLS_DIR/samtools view \
$CORE_PATH/$PROJECT/BAM/$SM_TAG.bam \
| tail -n+100000 \
| $LUMPY_DIR/../scripts/pairend_distro.py \
-r $READ_LENGTH \
-X 4 \
-N 10000 \
-o $CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.hist.txt"

END_HIST=`date '+%s'`

echo $SM_TAG"_"$PROJECT",H.01,HIST,"$HOSTNAME","$START_HIST","$END_HIST\
>> $CORE_PATH/$PROJECT/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $SAMTOOLS_DIR/samtools view \
$CORE_PATH/$PROJECT/BAM/$SM_TAG.bam \
| tail -n+100000 \
| $LUMPY_DIR/../scripts/pairend_distro.py \
-r $READ_LENGTH \
-X 4 \
-N 10000 \
-o $CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort.hist.txt" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
