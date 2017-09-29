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

CORE_PATH=$2
PROJECT=$3
SM_TAG=$4

# sort the file

START_SORT_DISCORDANT_PE=`date '+%s'`

$SAMTOOLS_DIR/samtools sort $CORE_PATH/$PROJECT/LUMPY/TEMP/$SM_TAG".lumpy.discordant.pe.bam" \
$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort"

END_SORT_DISCORDANT_PE=`date '+%s'`

echo $SM_TAG"_"$PROJECT",I.01,SORT_DISCORDANT_PE,"$HOSTNAME","$START_SORT_DISCORDANT_PE","$END_SORT_DISCORDANT_PE\
>> $CORE_PATH/$PROJECT/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $SAMTOOLS_DIR/samtools sort $CORE_PATH/$PROJECT/TEMP/$SM_TAG".lumpy.discordant.pe.bam" \
$CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.pe.sort" \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
