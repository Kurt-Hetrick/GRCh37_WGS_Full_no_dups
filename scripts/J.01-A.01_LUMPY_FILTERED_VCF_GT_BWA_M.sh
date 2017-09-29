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

SVTYPER_DIR=$1

CORE_PATH=$2
PROJECT=$3
SM_TAG=$4

# the default here is to assume that the reads are aligned with bwa_mem, but without the -M argument
# need to add a switch here to add to cmd line -M when the bam has been created with bwa mem -M


START_SVTYPER_FILTERED=`date '+%s'`

$SVTYPER_DIR/svtyper \
-B $CORE_PATH/$PROJECT/BAM/$SM_TAG.bam \
-S $CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.split.reads.sort.bam" \
-i $CORE_PATH/$PROJECT/LUMPY/VCF/$SM_TAG.LUMPY.FILTERED.vcf \
-M \
>| $CORE_PATH/$PROJECT/LUMPY/VCF/$SM_TAG.LUMPY.FILTERED.GT.vcf

END_SVTYPER_FILTERED=`date '+%s'`

echo $SM_TAG"_"$PROJECT",K.01,SVTYPER_FILTERED,"$HOSTNAME","$START_SVTYPER_FILTERED","$END_SVTYPER_FILTERED\
>> $CORE_PATH/$PROJECT/$PROJECT".WALL.CLOCK.TIMES.csv"

echo $SVTYPER_DIR/svtyper \
-B $CORE_PATH/$PROJECT/BAM/$SM_TAG.bam \
-S $CORE_PATH/$PROJECT/LUMPY/BAM/$SM_TAG".lumpy.discordant.split.reads.sort.bam" \
-i $CORE_PATH/$PROJECT/LUMPY/VCF/$SM_TAG.LUMPY.FILTERED.vcf \
-M \
\>\| $CORE_PATH/$PROJECT/LUMPY/VCF/$SM_TAG.LUMPY.FILTERED.GT.vcf \
>> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
