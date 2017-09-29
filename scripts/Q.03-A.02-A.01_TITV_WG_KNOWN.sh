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

SAMTOOLS_DIR=$1
CORE_PATH=$2

PROJECT=$3
SM_TAG=$4

# TI/TV WG KNOWN

START_TITV_WG_KNOWN=`date '+%s'`

zcat $CORE_PATH/$PROJECT/TEMP/$SM_TAG".QC.WG.Known.TiTv.vcf.gz" \
| $SAMTOOLS_DIR/bcftools/vcfutils.pl qstats /dev/stdin \
>| $CORE_PATH/$PROJECT/REPORTS/TI_TV/WHOLE_GENOME/$SM_TAG"_WG_Known_titv.txt"

END_TITV_WG_KNOWN=`date '+%s'`

HOSTNAME=`hostname`

echo $SM_TAG"_"$PROJECT",S.01,TITV_WG_KNOWN,"$HOSTNAME","$START_TITV_WG_KNOWN","$END_TITV_WG_KNOWN \
>> $CORE_PATH/$PROJECT/REPORTS/$PROJECT".WALL.CLOCK.TIMES.csv"

# echo zcat $$CORE_PATH/$PROJECT/TEMP/$SM_TAG".QC.WG.Known.TiTv.vcf.gz" \
# | $SAMTOOLS_DIR/bcftools/vcfutils.pl qstats /dev/stdin \
# \>\| $CORE_PATH/$PROJECT/REPORTS/TI_TV/WHOLE_GENOME/$SM_TAG"_WG_Known_titv.txt" \
# >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"

echo >> $CORE_PATH/$PROJECT/COMMAND_LINES/$SM_TAG".COMMAND_LINES.txt"
