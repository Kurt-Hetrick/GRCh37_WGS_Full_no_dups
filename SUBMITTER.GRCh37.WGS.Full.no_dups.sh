#!/bin/bash

module load sge

SAMPLE_SHEET=$1

# CHANGE SCRIPT DIR TO WHERE YOU HAVE HAVE THE SCRIPTS BEING SUBMITTED

SCRIPT_DIR="/isilon/sequencing/Kurt/GIT_REPO/GRCh37_WGS_Full_no_dups/scripts"

CORE_PATH="/isilon/sequencing/Seq_Proj/"

# PIPELINE PROGRAMS
JAVA_1_8="/isilon/sequencing/Kurt/Programs/Java/jdk1.8.0_73/bin"
JAVA_1_7="/isilon/sequencing/Kurt/Programs/Java/jdk1.7.0_25/bin"
JAVA_CIDRSEQSUITE="/isilon/sequencing/CIDRSeqSuiteSoftware/java/jre1.7.0_45/bin"
BWA_DIR="/isilon/sequencing/Kurt/Programs/BWA/bwa-0.7.8"
PICARD_DIR="/isilon/sequencing/Kurt/Programs/Picard/picard-tools-1.109"
PICARD_DIR2="/isilon/sequencing/Kurt/Programs/Picard/picard-tools-1.126"
GATK_DIR="/isilon/sequencing/CIDRSeqSuiteSoftware/gatk/GATK_3/GenomeAnalysisTK-3.3-0"
VERIFY_DIR="/isilon/sequencing/Kurt/Programs/VerifyBamID/verifyBamID_20120620/bin/"
SAMTOOLS_DIR="/isilon/sequencing/Kurt/Programs/samtools/samtools-0.1.18"
TABIX_DIR="/isilon/sequencing/Kurt/Programs/TABIX/tabix-0.2.6"
DATAMASH_DIR="/isilon/sequencing/Kurt/Programs/DATAMASH/datamash-1.0.6"
BEDTOOLS_DIR="/isilon/sequencing/Kurt/Programs/BEDTOOLS/bedtools-2.22.0/bin"
VCFTOOLS_DIR="/isilon/sequencing/Kurt/Programs/VCFtools/vcftools_0.1.12b/bin"
PLINK2_DIR="/isilon/sequencing/Kurt/Programs/PLINK2"
KING_DIR="/isilon/sequencing/Kurt/Programs/KING/Linux-king19"
LUMPY_DIR="/isilon/sequencing/Kurt/Programs/LUMPY/lumpy-sv-0.2.13-649309b/bin"
SVTYPER_DIR="/isilon/sequencing/Kurt/Programs/SVTyper/svtyper-0.1.4"
CIDRSEQSUITE_6_1_1="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/6.1.1"

module load anaconda-python/2.7.12

# PIPELINE FILES
GENE_LIST="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/RefSeqGene.GRCh37.Ready.txt"
# VERIFY_VCF="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/Omni25_genotypes_1525_samples_v2.b37.PASS.ALL.sites.vcf"
VERIFY_VCF="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/Omni25_genotypes_1525_samples_v2.b37.PASS.ALL.sites.DS_2PCT.vcf"
CODING_BED="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/UCSC_hg19_CodingOnly_083013_MERGED_noContigs_noCHR.bed"
CYTOBAND_BED="/isilon/sequencing/Kurt/CGC/GRCh37.Cytobands.bed"
CODING_BED_MT="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/MT.coding.bed"
TRANSCRIPT_BED="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/Transcripts.UCSC.Merged.NoContigsAlts.bed"
TRANSCRIPT_BED_MT="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/MT.transcripts.bed"
GAP_BED="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/GRCh37.gaps.bed"
NO_GAP_BED="/isilon/sequencing/CIDRSeqSuiteSoftware/RELEASES/5.0.0/aux_files/grch37.nogap.nochr.bed"
VERACODE="/isilon/sequencing/CIDRSeqSuiteSoftware/resources/Veracode_hg18_hg19.csv"

HAPMAP="/isilon/sequencing/GATK_resource_bundle/2.5/b37/hapmap_3.3.b37.vcf"
OMNI_1KG="/isilon/sequencing/GATK_resource_bundle/2.5/b37/1000G_omni2.5.b37.vcf"
HI_CONF_1KG_PHASE1_SNP="/isilon/sequencing/GATK_resource_bundle/2.5/b37/1000G_phase1.snps.high_confidence.b37.vcf"
MILLS_1KG_GOLD_INDEL="/isilon/sequencing/GATK_resource_bundle/2.2/b37/Mills_and_1000G_gold_standard.indels.b37.vcf"
PHASE3_1KG_AUTOSOMES="/isilon/sequencing/1000genomes/Full_Project/Sep_2014/20130502/ALL.autosomes.phase3_shapeit2_mvncall_integrated_v5.20130502.sites.vcf"
DBSNP_129="/isilon/sequencing/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.excluding_sites_after_129.vcf"

GATK_KEY="/isilon/sequencing/CIDRSeqSuiteSoftware/gatk/GATK_2/lee.watkins_jhmi.edu.key"

#################################
##### MAKE A DIRECTORY TREE #####
#################################

SETUP_PROJECT ()
{
CREATE_SAMPLE_INFO_ARRAY
MAKE_PROJ_DIR_TREE
echo Project started at `date` >| $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/PROJECT_START_END_TIMESTAMP.txt
}

# MAKE AN ARRAY FOR EACH SAMPLE
	## SAMPLE_INFO_ARRAY[0] = PROJECT
	## SAMPLE_INFO_ARRAY[1] = SM_TAG
	## SAMPLE_INFO_ARRAY[2] = REFERENCE_GENOME
	## SAMPLE_INFO_ARRAY[3] = KNOWN_INDEL_1
	## SAMPLE_INFO_ARRAY[4] = KNOWN_INDEL_2
	## SAMPLE_INFO_ARRAY{5] = DBSNP

CREATE_SAMPLE_INFO_ARRAY ()
{
SAMPLE_INFO_ARRAY=(`sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk '$8=="'$SAMPLE'" {split($19,INDEL,";"); print $1,$8,$12,INDEL[1],INDEL[2],$18}'`)
}

# PROJECT DIRECTORY TREE CREATOR

MAKE_PROJ_DIR_TREE ()
{
mkdir -p $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/{BAM,GVCF,LOGS,TEMP,FASTQ,BED_Files,COMMAND_LINES} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/{ALIGNMENT_SUMMARY,ANNOVAR,DUPLICATES,QC_REPORTS,TI_TV,TI_TV_MS,VERIFY_BAM_ID,SAMPLE_SHEETS,OXIDATION} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/TI_TV/{WHOLE_GENOME,CODING} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/TI_TV_MS/{WHOLE_GENOME,CODING} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/BASECALL_Q_SCORE_DISTRIBUTION/{METRICS,PDF} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/CONCORDANCE/{SINGLE,MULTI} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/COUNT_COVARIATES/{GATK_REPORT,PDF} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/GC_BIAS/{METRICS,PDF,SUMMARY} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/INSERT_SIZE/{METRICS,PDF} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/LOCAL_REALIGNMENT_INTERVALS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/MEAN_QUALITY_BY_CYCLE/{METRICS,PDF} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/REPORTS/DEPTH_OF_COVERAGE/{DEPTH_SUMMARY,CODING_COVERAGE,TRANSCRIPT_COVERAGE} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/VCF/SINGLE/WHOLE_GENOME/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/VCF/SINGLE/CODING/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/VCF/MULTI/WHOLE_GENOME/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/VCF/MULTI/CODING/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/SNV/SINGLE/WHOLE_GENOME/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/SNV/SINGLE/CODING/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/SNV/MULTI/WHOLE_GENOME/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/SNV/MULTI/CODING/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/INDEL/SINGLE/WHOLE_GENOME/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/INDEL/SINGLE/CODING/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/INDEL/MULTI/WHOLE_GENOME/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/INDEL/MULTI/CODING/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/MIXED/SINGLE/WHOLE_GENOME/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/MIXED/SINGLE/CODING/PASS \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/MIXED/MULTI/WHOLE_GENOME/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/MIXED/MULTI/CODING/{PASS_ALL,PASS_VARIANT} \
$CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LUMPY/{BAM,TEMP,VCF}
}

for SAMPLE in $(sed 's/\r//g' $SAMPLE_SHEET | awk 'BEGIN {FS=","} NR>1 {print $8}' | sort | uniq );
do
SETUP_PROJECT
done

############################################################

# to create the qsub cmd line to submit bwa alignments to the cluster
# handle blank lines
# handle something else too

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk '{split($18,INDEL,";");split($8,smtag,"[@-]"); \
print "qsub","-N","A.01_BWA_"$8"_"$2"_"$3"_"$4,\
"-pe slots 3 -R y",\
"-j y",\
"-o","'$CORE_PATH'/"$1"/LOGS/"$8"_"$2"_"$3"_"$4".BWA.log",\
"'$SCRIPT_DIR'""/A.01_BWA.sh",\
"'$BWA_DIR'","'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$12"\n""sleep 1s"}'

# create a hold job id qsub command line based on the number of
# submit merging the bam files created by bwa mem above
# only launch when every lane for a sample is done being processed by bwa mem

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$2"_"$3"_"$4,$2"_"$3"_"$4".sam"}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| $DATAMASH_DIR/datamash -s -g 1,2 collapse 3 collapse 4 \
| awk 'BEGIN {FS="\t"} \
gsub(/,/,",A.01_BWA_"$2"_",$3) \
gsub(/,/,",INPUT=/isilon/sequencing/Seq_Proj/"$1"/TEMP/",$4) \
{print "qsub","-N","B.01_MERGE_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".MERGE.BAM.FILES.log",\
"-hold_jid","A.01_BWA_"$2"_"$3, \
"'$SCRIPT_DIR'""/B.01_MERGE_SORT_AGGRO.sh",\
"'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,"INPUT=/isilon/sequencing/Seq_Proj/"$1"/TEMP/"$4"\n""sleep 1s"}'

# # Mark duplicates on the bam file above. Create a Mark Duplicates report which goes into the QC report
# 
# sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
# | awk 'NR>1' \
# | sort -k 8,8 \
# | awk 'BEGIN {OFS="\t"} {print $1,$8}' \
# | sort -k 1,1 -k 2,2 \
# | uniq \
# | awk '{split($2,smtag,"[@-]"); \
# print "qsub","-N","C.01_MARK_DUPLICATES_"$2"_"$1,\
# "-l mem_free=48G",\
# "-hold_jid","B.01_MERGE_BAM_"$2"_"$1,\
# "-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".MARK_DUPLICATES.log",\
# "'$SCRIPT_DIR'""/C.01_MARK_DUPLICATES.sh",\
# "'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

# Generate a list of places that could be potentially realigned {{1.22},{X,Y,MT}}

REALIGNER_TARGET_CREATOR ()
{
echo \
qsub \
-N D.01_REALIGNER_TARGET_CREATOR_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}_chr$CHROMOSOME \
-hold_jid B.01_MERGE_BAM_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.REALIGNER_TARGET_CREATOR_chr$CHROMOSOME.log \
$SCRIPT_DIR/D.01_REALIGNER_TARGET_CREATOR.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]} ${SAMPLE_INFO_ARRAY[3]} \
${SAMPLE_INFO_ARRAY[4]} $CHROMOSOME
}

INDEL_REALIGNER ()
{
echo \
qsub \
-N E.01_INDEL_REALIGNER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}_chr$CHROMOSOME \
-hold_jid D.01_REALIGNER_TARGET_CREATOR_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}_chr$CHROMOSOME \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.INDEL_REALIGNER_chr$CHROMOSOME.log \
$SCRIPT_DIR/E.01_INDEL_REALIGNER.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]} ${SAMPLE_INFO_ARRAY[3]} \
${SAMPLE_INFO_ARRAY[4]} $CHROMOSOME
}

for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
do
CREATE_SAMPLE_INFO_ARRAY
	for CHROMOSOME in {{1..22},{X,Y,MT}}
		do
		REALIGNER_TARGET_CREATOR
		INDEL_REALIGNER
		echo sleep 1s
		done
	done

# Print out all of the junk alignments and set them off to side

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","D.02_PRINT_JUNK_ALIGNMENTS_"$2"_"$1,\
"-hold_jid","B.01_MERGE_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".PRINT_JUNK_ALIGNMENTS.log",\
"'$SCRIPT_DIR'""/D.02_PRINT_JUNK_ALIGNMENTS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

################################################################

# Run Base Quality Score Recalibration ON AUTOSOMAL LOCALLY REALIGNED BAM FILES

BUILD_HOLD_ID_PATH_BQSR ()
{
	for PROJECT in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $1}' | sort | uniq )
	do
	HOLD_ID_PATH="-hold_jid "
	for CHROMOSOME in {1..22};
 	do
 		HOLD_ID_PATH=$HOLD_ID_PATH"E.01_INDEL_REALIGNER_"$SAMPLE"_"$PROJECT"_chr"$CHROMOSOME","
 	done
 done
}

BQSR ()
{
echo \
qsub \
-N F.01_PERFORM_BQSR_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
-l mem_free=46G -R y \
${HOLD_ID_PATH} \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.PERFORM_BQSR.log \
$SCRIPT_DIR/F.01_PERFORM_BQSR.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]} ${SAMPLE_INFO_ARRAY[3]} \
${SAMPLE_INFO_ARRAY[4]} ${SAMPLE_INFO_ARRAY[5]}
}

for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq );
 do
	BUILD_HOLD_ID_PATH_BQSR
	CREATE_SAMPLE_INFO_ARRAY
	BQSR
	echo sleep 1s
 done

# # write Final Bam file

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","G.01_FINAL_BAM_"$2"_"$1,\
"-hold_jid","F.01_PERFORM_BQSR_"$2"_"$1",D.02_PRINT_JUNK_ALIGNMENTS_"$2"_"$1,\
"-l mem_free=15G -R y",\
"-j y",\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".FINAL_BAM.log",\
"'$SCRIPT_DIR'""/G.01_FINAL_BAM.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# SCATTER THE HAPLOTYPE CALLER GVCF CREATION USING THE WHERE THE BED INTERSECTS WITH {{1.22},{X,Y,MT}}

CALL_HAPLOTYPE_CALLER ()
{
echo \
qsub \
-N H.01_HAPLOTYPE_CALLER_${SAMPLE_INFO_ARRAY[0]}_${SAMPLE_INFO_ARRAY[1]}_chr$CHROMOSOME \
-hold_jid G.01_FINAL_BAM_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.HAPLOTYPE_CALLER_chr$CHROMOSOME.log \
$SCRIPT_DIR/H.01_HAPLOTYPE_CALLER_SCATTER_PCR_FREE.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]} $CHROMOSOME
}

for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
do
CREATE_SAMPLE_INFO_ARRAY
	for CHROMOSOME in {{1..22},{X,Y,MT}}
		do
		CALL_HAPLOTYPE_CALLER
		echo sleep 1s
		done
	done

################################################################

# GATHER UP THE PER SAMPLE PER CHROMOSOME GVCF FILES INTO A SINGLE SAMPLE GVCF

BUILD_HOLD_ID_PATH(){
	for PROJECT in $(awk 'BEGIN {FS=","} NR>1 {print $1}' $SAMPLE_SHEET | sort | uniq )
	do
	HOLD_ID_PATH="-hold_jid "
	for CHROMOSOME in {{1..22},{X,Y,MT}};
 	do
 		HOLD_ID_PATH=$HOLD_ID_PATH"H.01_HAPLOTYPE_CALLER_"$PROJECT"_"$SAMPLE"_chr"$CHROMOSOME","
 	done
 done
}

CALL_HAPLOTYPE_CALLER_GATHER ()
{
echo \
qsub \
-N H.01-A.01_HAPLOTYPE_CALLER_GATHER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
${HOLD_ID_PATH} \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.HAPLOTYPE_CALLER_GATHER.log \
$SCRIPT_DIR/H.01-A.01_HAPLOTYPE_CALLER_GATHER.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]}
}


for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
 do
	BUILD_HOLD_ID_PATH
	CREATE_SAMPLE_INFO_ARRAY
	CALL_HAPLOTYPE_CALLER_GATHER
	echo sleep 1s
 done

# Run POST BQSR TABLE

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12,$19,$18}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($4,INDEL,";"); split($2,smtag,"[@-]"); \
print "qsub","-N","H.02_POST_BQSR_TABLE_"$2"_"$1,\
"-l mem_free=46G",\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".POST_BQSR_TABLE.log",\
"'$SCRIPT_DIR'""/H.02_POST_BQSR_TABLE.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3,INDEL[1],INDEL[2],$5"\n""sleep 1s"}'

# Run ANALYZE COVARIATES

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.02-A.01_ANALYZE_COVARIATES_"$2"_"$1,\
"-hold_jid","H.02_POST_BQSR_TABLE_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".ANALYZE_COVARIATES.log",\
"'$SCRIPT_DIR'""/H.02-A.01_ANALYZE_COVARIATES.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# Run Depth of Coverage on UCSC autosomal coding regions.

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.03_AUTO_DOC_CODING_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".DOC_AUTO_CODING.log",\
"'$SCRIPT_DIR'""/H.03_DOC_AUTO_CODING.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

# Run Depth of Coverage on autosomal chromosomes.

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.04_DOC_AUTO_WG_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".DOC_AUTO_WG.log",\
"'$SCRIPT_DIR'""/H.04_DOC_AUTO_WG.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GAP_BED'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

# Run Depth of Coverage interval summaries on coding regions.

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.05_DOC_CODING_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".DOC_CODING.log",\
"'$SCRIPT_DIR'""/H.05_DOC_CODING.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GENE_LIST'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

# Run Depth of Coverage interval summaries on transcripts.

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.06_DOC_TRANSCRIPT_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".DOC_TRANSCRIPT.log",\
"'$SCRIPT_DIR'""/H.06_DOC_TRANSCRIPT.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$TRANSCRIPT_BED'","'$TRANSCRIPT_BED_MT'","'$GENE_LIST'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

# Run verifyBamID

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.07_VERIFYBAMID_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".VERIFYBAMID.log",\
"'$SCRIPT_DIR'""/H.07_VERIFYBAMID.sh",\
"'$JAVA_1_7'","'$VERIFY_DIR'","'$CORE_PATH'","'$VERIFY_VCF'",$1,$2"\n""sleep 1s"}'


# Don't forget to implement this instead of several programs down below!!!!!
# # RUN COLLECT MULTIPLE METRICS
#
# awk 'BEGIN {OFS="\t"} {print $1,$19,$8,$12,$17,$14}' \
# ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt \
# | sort -k 1,1 -k 2,2 -k 3,3 \
# | uniq \
# | awk '{split($3,smtag,"[@-]"); \
# print "qsub","-N","H.06_COLLECT_MULTIPLE_METRICS_"$3"_"$1,\
# "-hold_jid","G.01_FINAL_BAM_"$3"_"$1,\
# "-o","'$CORE_PATH'/"$1"/"$2"/"$3"/LOGS/"$3"_"$1".COLLECT_MULTIPLE_METRICS.log",\
# "'$SCRIPT_DIR'""/H.06_COLLECT_MULTIPLE_METRICS.sh",\
# "'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'","'$SAMTOOLS_DIR'",$1,$2,$3,$4,$5,$6"\n""sleep 1s"}'

# Run Insert Size

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.08_INSERT_SIZE_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".INSERT_SIZE.log",\
"'$SCRIPT_DIR'""/H.08_INSERT_SIZE.sh",\
"'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# Run Alignment Summary Metrics

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.09_ALIGNMENT_SUMMARY_METRICS_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".ALIGNMENT_SUMMARY_METRICS.log",\
"'$SCRIPT_DIR'""/H.09_ALIGNMENT_SUMMARY_METRICS.sh",\
"'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# Run BaseCall Quality Score Distribution

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.10_BASECALL_Q_SCORE_DISTRIBUTION_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".BASECALL_Q_SCORE_DISTRIBUTION.log",\
"'$SCRIPT_DIR'""/H.10_BASECALL_Q_SCORE_DISTRIBUTION.sh",\
"'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# Run GC BIAS

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.11_GC_BIAS_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".GC_BIAS.log",\
"'$SCRIPT_DIR'""/H.11_GC_BIAS.sh",\
"'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# Run MEAN QUALITY BY CYCLE

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.12_MEAN_QUALITY_BY_CYCLE_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".MEAN_QUALITY_BY_CYCLE.log",\
"'$SCRIPT_DIR'""/H.12_MEAN_QUALITY_BY_CYCLE.sh",\
"'$JAVA_1_7'","'$PICARD_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

# Run OXIDATION

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12,$18}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.13_OXIDATION_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".OXIDATION.log",\
"'$SCRIPT_DIR'""/H.13_OXIDATION.sh",\
"'$SAMTOOLS_DIR'","'$JAVA_1_7'","'$PICARD_DIR2'","'$CORE_PATH'",$1,$2,$3,$4"\n""sleep 1s"}'

# Run Estimate Library

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","H.99_ESTIMATE_LIBRARY_"$2"_"$1,\
"-hold_jid","G.01_FINAL_BAM_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".ESTIMATE_LIBRARY.log",\
"'$SCRIPT_DIR'""/H.99_ESTIMATE_LIBRARY.sh",\
"'$JAVA_1_7'","'$PICARD_DIR2'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

#################
##### LUMPY #####
#################

# MAKE AN ARRAY FOR EACH SAMPLE
	## SAMPLE_INFO_ARRAY[0] = PROJECT
	## SAMPLE_INFO_ARRAY[1] = SM_TAG
	## SAMPLE_INFO_ARRAY[2] = REFERENCE_GENOME
	## SAMPLE_INFO_ARRAY[3] = KNOWN_INDEL_1
	## SAMPLE_INFO_ARRAY[4] = KNOWN_INDEL_2
	## SAMPLE_INFO_ARRAY{5] = DBSNP

CREATE_SAMPLE_INFO_ARRAY ()
{
SAMPLE_INFO_ARRAY=(`sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk '$8=="'$SAMPLE'" {split($19,INDEL,";"); print $1,$8,$12,INDEL[1],INDEL[2],$18}'`)
}

DISCORDANT_PE(){
echo \
 qsub -q $QUEUE_LIST \
 -N H14_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid G.01_FINAL_BAM_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_DISCORDANT_PE.log \
 $SCRIPT_DIR/H.14_DISCORDANT_PE.sh \
 $SAMTOOLS_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
 }
 
SPLIT_READ(){
echo \
 qsub -q $QUEUE_LIST \
 -N H15_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid G.01_FINAL_BAM_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_SPLIT_READ.log \
 $SCRIPT_DIR/H.15_SPLIT_READ.sh \
 $SAMTOOLS_DIR $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
 }
 
DISCORDANT_PE_HIST(){
echo \
 qsub -q $QUEUE_LIST \
 -N H16_DISCORDANT_PE_HIST_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid G.01_FINAL_BAM_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H.09_ALIGNMENT_SUMMARY_METRICS_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_DISCORDANT_PE_HIST.log \
 $SCRIPT_DIR/H.16_DISCORDANT_PE_HIST.sh \
 $SAMTOOLS_DIR $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
 }

### i actually don't think I need this either ###

SORT_DISCORDANT_PE(){
echo \
 qsub -q $QUEUE_LIST \
 -N H14_A01_SORT_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H14_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_SORT_DISCORDANT_PE.log \
 $SCRIPT_DIR/H.14-A.01_SORT_DISCORDANT_PE.sh \
 $SAMTOOLS_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### i actually don't think i need this ###

SORT_SPLIT_READ(){
echo \
 qsub -q $QUEUE_LIST \
 -N H15_A01_SORT_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H15_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_SORT_SPLIT_READ.log \
 $SCRIPT_DIR/H.15-A.01_SORT_SPLIT_READ.sh \
 $SAMTOOLS_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### CAN TAKE OUT THE BELOW ### SHOULD NOT NEED TO THIS ANYMORE

INDEX_SPLIT_READ(){
echo \
 qsub -q $QUEUE_LIST \
 -N H15_A01_A01_INDEX_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H15_A01_INDEX_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_INDEX_SPLIT_READ.log \
 $SCRIPT_DIR/H.15-A.01-A.01_INDEX_SPLIT_READ.sh \
 $SAMTOOLS_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### CAN TAKE OUT THE BELOW ### SHOULD NOT NEED TO THIS ANYMORE

INDEX_DISCORDANT_PE(){
echo \
 qsub -q $QUEUE_LIST \
 -N H14_A01_A01_INDEX_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H14_A01_SORT_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_INDEX_DISCORDANT_PE.log \
 $SCRIPT_DIR/H.14-A.01-A.01_INDEX_DISCORDANT_PE.sh \
 $SAMTOOLS_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### start the rework here ###

### NOT SURE THAT I NEED THIS ANYMORE...PROBABLY CAN TAKE OUT.

CREATE_LUMPY_COVERAGE(){
echo \
 qsub -q $QUEUE_LIST \
 -N I01_LUMPY_COVERAGE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H14_A01_SORT_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H15_A01_SORT_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_COVERAGE.log \
 $SCRIPT_DIR/I.01_LUMPY_COVERAGE.sh \
 $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

# DONE

LUMPY_ALL_VCF(){
echo \
 qsub -q $QUEUE_LIST \
 -N I02_LUMPY_ALL_VCF_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H14_A01_SORT_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H15_A01_SORT_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},\
H.09_ALIGNMENT_SUMMARY_METRICS_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H.08_INSERT_SIZE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},\
H16_DISCORDANT_PE_HIST_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_ALL_VCF.log \
 $SCRIPT_DIR/I.02_LUMPY_ALL_VCF.sh \
 $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

# DONE

### svtyper
# NEED TO IMPORT ANACONDA HERE SOMEHOW SOMEDAY
# MIGHT WANT TO FILTER LCR,HIGH DEPTH, DECOY UPFRONT

SVTYPER(){
echo \
 qsub -q $QUEUE_LIST \
 -N I02-A.01_SVTYPER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid I02_LUMPY_ALL_VCF_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_SVTYPER.log \
 $SCRIPT_DIR/I.02-A.01_SVTYPER.sh \
 $SVTYPER_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### DONE

FILTER_SVTYPER(){
echo \
 qsub -q $QUEUE_LIST \
 -N I02-A.01-A.01_FILTER_SVTYPER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid I02-A.01_SVTYPER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_FILTER_SVTYPER.log \
 $SCRIPT_DIR/I.02-A.01-A.01_FILTER_SVTYPER.sh \
 $JAVA_1_7 $GATK_DIR ${SAMPLE_INFO_ARRAY[2]} $LCR $LUMPY_EXCLUDE $GATK_KEY $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### DONE

SVTYPER_TO_TABLE(){
echo \
 qsub -q $QUEUE_LIST \
 -N I02-A.01-A.02_SVTYPER_TO_TABLE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid I02-A.01_SVTYPER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_SVTYPER_TO_TABLE.log \
 $SCRIPT_DIR/I.02-A.01-A.02_SVTYPER_TO_TABLE.sh \
 $JAVA_1_7 $GATK_DIR ${SAMPLE_INFO_ARRAY[2]} $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### DONE

FILTERED_SVTYPER_TO_TABLE(){
echo \
 qsub -q $QUEUE_LIST \
 -N I02-A.01-A.01-A.01_FILTERED_SVTYPER_TO_TABLE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid I02-A.01-A.01_FILTER_SVTYPER_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_FILTERED_SVTYPER_TO_TABLE.log \
 $SCRIPT_DIR/I.02-A.01-A.01-A.01_FILTERED_SVTYPER_TO_TABLE.sh \
 $JAVA_1_7 $GATK_DIR ${SAMPLE_INFO_ARRAY[2]} $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

### KEEPING THIS IN HERE FOR NOW, BUT I DON'T THINK THAT THIS ADDS ANYMORE VALUE ANYMORE

LUMPY_ALL_BEDPE(){
echo \
 qsub -q $QUEUE_LIST \
 -N I03_LUMPY_ALL_BEDPE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -hold_jid H14_A01_SORT_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H15_A01_SORT_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},\
H.09_ALIGNMENT_SUMMARY_METRICS_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H.08_INSERT_SIZE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},\
H16_DISCORDANT_PE_HIST_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
 -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_ALL_BEDPE.log \
 $SCRIPT_DIR/I.03_LUMPY_ALL_BEDPE.sh \
 $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
}

# DONE
 
##### Taking this out since they don't even use it anymore and it is not written for parallelization across a cluster

# LUMPY_EXCLUDE_BED(){
# echo \
#  qsub -q $QUEUE_LIST \
#  -N I04_LUMPY_EXCLUDE_BED_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
#  -hold_jid H14_A01_SORT_DISCORDANT_PE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H15_A01_SORT_SPLIT_READ_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},\
# I01_LUMPY_COVERAGE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},H.03_AUTO_DOC_CODING_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
#  -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_EXCLUDE_BED.log \
#  $SCRIPT_DIR/I.04_LUMPY_EXCLUDE_BED.sh \
#  $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
# }

# ### basically moving this up to filter svtyper
# 
# LUMPY_FILTER_VCF(){
# echo \
#  qsub -q $QUEUE_LIST \
#  -N J01_LUMPY_FILTER_VCF_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
#  -hold_jid I02_LUMPY_ALL_VCF_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]},I04_LUMPY_EXCLUDE_BED_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
#  -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_FILTER_VCF.log \
#  $SCRIPT_DIR/J.01_LUMPY_FILTER_VCF.sh \
#  $JAVA_1_7 $GATK_DIR ${SAMPLE_INFO_ARRAY[2]} $LCR $GATK_KEY $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
# }

### NEED TO REWORK SCRIPT
### YEAH, I'M NOT DOING THIS ###
# 
# LUMPY_FILTER_BEDPE(){
# echo \
#  qsub -q $QUEUE_LIST \
#  -N J02_LUMPY_FILTER_BEDPE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
#  -hold_jid I03_LUMPY_ALL_BEDPE_${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]} \
#  -j y -o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_LUMPY_FILTER_BEDPE.log \
#  $SCRIPT_DIR/J.02_LUMPY_FILTER_BEDPE.sh \
#  $LUMPY_DIR $CORE_PATH ${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]}
# }

### SHOULD DO VCF TO TABLE

for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
 do
CREATE_SAMPLE_INFO_ARRAY
DISCORDANT_PE
echo sleep 0.1s
SPLIT_READ
echo sleep 0.1s
DISCORDANT_PE_HIST
echo sleep 0.1s
SORT_DISCORDANT_PE
echo sleep 0.1s
SORT_SPLIT_READ
echo sleep 0.1s
INDEX_SPLIT_READ
echo sleep 0.1s
INDEX_DISCORDANT_PE
echo sleep 0.1s
CREATE_LUMPY_COVERAGE
echo sleep 0.1s
LUMPY_ALL_VCF
echo sleep 0.1s
SVTYPER
echo sleep 0.1s
FILTER_SVTYPER
echo sleep 0.1s
SVTYPER_TO_TABLE
echo sleep 0.1s
LUMPY_ALL_BEDPE
echo sleep 0.1s
FILTERED_SVTYPER_TO_TABLE
echo sleep 0.1s
# LUMPY_EXCLUDE_BED
echo sleep 0.1s
# LUMPY_FILTER_VCF
echo sleep 0.1s
# LUMPY_FILTER_BEDPE
 done

# CALLING VARIANTS

CALL_GENOTYPE_GVCF ()
{
echo \
qsub \
-N K.01_GENOTYPE_GVCF_${SAMPLE_INFO_ARRAY[0]}_${SAMPLE_INFO_ARRAY[1]}_chr$CHROMOSOME \
-hold_jid H.01_HAPLOTYPE_CALLER_${SAMPLE_INFO_ARRAY[0]}_${SAMPLE_INFO_ARRAY[1]}_chr$CHROMOSOME \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.GENOTYPE_GVCF_chr$CHROMOSOME.log \
$SCRIPT_DIR/K.01_GENOTYPE_GVCF.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]} $CHROMOSOME
}

for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
do
CREATE_SAMPLE_INFO_ARRAY
	for CHROMOSOME in {{1..22},{X,Y,MT}}
		do
		CALL_GENOTYPE_GVCF
		echo sleep 1s
		done
	done

CALL_ANNOTATE_VCF ()
{
echo \
qsub \
-N L.01_ANNOTATE_VCF_${SAMPLE_INFO_ARRAY[0]}_${SAMPLE_INFO_ARRAY[1]}_chr$CHROMOSOME \
-hold_jid K.01_GENOTYPE_GVCF_${SAMPLE_INFO_ARRAY[0]}_${SAMPLE_INFO_ARRAY[1]}_chr$CHROMOSOME \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.ANNOTATE_VCF_chr$CHROMOSOME.log \
$SCRIPT_DIR/L.01_ANNOTATE_VCF.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]} ${SAMPLE_INFO_ARRAY[5]} $CHROMOSOME
}

for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
do
CREATE_SAMPLE_INFO_ARRAY
	for CHROMOSOME in {{1..22},{X,Y,MT}}
		do
		CALL_ANNOTATE_VCF
		echo sleep 1s
		done
	done

################################################################

# GATHER UP THE PER SAMPLE PER CHROMOSOME GVCF FILES INTO A SINGLE SAMPLE GVCF

BUILD_HOLD_ID_PATH_VCF(){
	for PROJECT in $(awk 'BEGIN {FS=","} NR>1 {print $1}' $SAMPLE_SHEET | sort | uniq )
	do
	HOLD_ID_PATH="-hold_jid "
	for CHROMOSOME in {{1..22},{X,Y,MT}};
 	do
 		HOLD_ID_PATH=$HOLD_ID_PATH"L.01_ANNOTATE_VCF_"$PROJECT"_"$SAMPLE"_chr"$CHROMOSOME","
 	done
 done
}

CALL_GATHER_VCF ()
{
echo \
qsub \
-N M.01_GATHER_VCF_${SAMPLE_INFO_ARRAY[0]}_${SAMPLE_INFO_ARRAY[1]} \
${HOLD_ID_PATH} \
-o $CORE_PATH/${SAMPLE_INFO_ARRAY[0]}/LOGS/${SAMPLE_INFO_ARRAY[1]}_${SAMPLE_INFO_ARRAY[0]}.GATHER_VCF.log \
$SCRIPT_DIR/M.01_GATHER_VCF.sh \
$JAVA_1_7 $GATK_DIR $CORE_PATH \
${SAMPLE_INFO_ARRAY[0]} ${SAMPLE_INFO_ARRAY[1]} ${SAMPLE_INFO_ARRAY[2]}
}


for SAMPLE in $(sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET | awk 'NR>1 {print $8}' | sort | uniq);
 do
	BUILD_HOLD_ID_PATH_VCF
	CREATE_SAMPLE_INFO_ARRAY
	CALL_GATHER_VCF
	echo sleep 1s
 done

# VQSR

### Run Variant Recalibrator for the SNP model, this is done in parallel with the INDEL model

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","N.01_RUN_VQSR_SNV_"$1"_"$2,\
"-hold_jid","M.01_GATHER_VCF_"$1"_"$2,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".VARIANT_RECALIBRATOR_SNP.log",\
"'$SCRIPT_DIR'""/N.01_RUN_VQSR_SNV.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3,"'$HAPMAP'","'$OMNI_1KG'","'$HI_CONF_1KG_PHASE1_SNP'","'$DBSNP_129'""\n""sleep 1s"}'

### Run Variant Recalibrator for the INDEL model, this is done in parallel with the SNP model

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12,$18}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","N.02_RUN_VQSR_INDEL_"$2"_"$1,\
"-hold_jid","M.01_GATHER_VCF_"$1"_"$2,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".VARIANT_RECALIBRATOR_INDEL.log",\
"'$SCRIPT_DIR'""/N.02_RUN_VQSR_INDEL.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3,$4,"'$MILLS_1KG_GOLD_INDEL'""\n""sleep 1s"}'

### Run Apply Recalbration with the SNP model to the VCF file

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","O.01_APPLY_VQSR_SNP_"$2"_"$1,\
"-hold_jid","N.02_RUN_VQSR_INDEL_"$2"_"$1",N.01_RUN_VQSR_SNV_"$1"_"$2,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".APPLY_RECALIBRATION_SNP.log",\
"'$SCRIPT_DIR'""/O.01_APPLY_VQSR_SNV.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

### Run Apply Recalibration with the INDEL model to the VCF file.

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-hold_jid","O.01_APPLY_VQSR_SNP_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".APPLY_VQSR_INDEL.log",\
"'$SCRIPT_DIR'""/P.01_APPLY_VQSR_INDEL.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'",$1,$2,$3"\n""sleep 1s"}'

##################################
##### VCF BREAKOUTS AND TITV #####
##################################
##### WHOLE GENOME ###############
##################################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.01_EXTRACT_VCF_WG_PASS_VARIANT_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_VCF_WG_PASS_VARIANT.log",\
"'$SCRIPT_DIR'""/Q.01_EXTRACT_VCF_WG_PASS_VARIANT.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

############################
##### WHOLE GENOME SNV #####
############################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.02_EXTRACT_SNV_WG_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_SNV_WG.log",\
"'$SCRIPT_DIR'""/Q.02_EXTRACT_SNV_WG.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03_EXTRACT_SNV_WG_PASS_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_SNV_WG_PASS.log",\
"'$SCRIPT_DIR'""/Q.03_EXTRACT_SNV_WG_PASS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03-A.01_TITV_WG_"$2"_"$1,\
"-hold_jid","Q.03_EXTRACT_SNV_WG_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".TITV_WG.log",\
"'$SCRIPT_DIR'""/Q.03-A.01_TITV_WG.sh",\
"'$SAMTOOLS_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03-A.02_EXTRACT_WG_KNOWN_"$2"_"$1,\
"-hold_jid","Q.03_EXTRACT_SNV_WG_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_WG_KNOWN.log",\
"'$SCRIPT_DIR'""/Q.03-A.02_EXTRACT_WG_KNOWN.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$DBSNP_129'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03-A.02-A.01_TITV_WG_KNOWN_"$2"_"$1,\
"-hold_jid","Q.03-A.02_EXTRACT_WG_KNOWN_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".TITV_WG_KNOWN.log",\
"'$SCRIPT_DIR'""/Q.03-A.02-A.01_TITV_WG_KNOWN.sh",\
"'$SAMTOOLS_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03-A.03_EXTRACT_WG_NOVEL_"$2"_"$1,\
"-hold_jid","Q.03_EXTRACT_SNV_WG_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_WG_NOVEL.log",\
"'$SCRIPT_DIR'""/Q.03-A.03_EXTRACT_WG_NOVEL.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$DBSNP_129'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03-A.03-A.01_TITV_WG_NOVEL_"$2"_"$1,\
"-hold_jid","Q.03-A.03_EXTRACT_WG_NOVEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".TITV_WG_NOVEL.log",\
"'$SCRIPT_DIR'""/Q.03-A.03-A.01_TITV_WG_NOVEL.sh",\
"'$SAMTOOLS_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.03-A.04_CONCORDANCE_WG_"$2"_"$1,\
"-hold_jid","Q.03_EXTRACT_SNV_WG_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".CONCORDANCE_WG.log",\
"'$SCRIPT_DIR'""/Q.03-A.04_CONCORDANCE_WG.sh",\
"'$JAVA_CIDRSEQSUITE'","'$CIDRSEQSUITE_6_1_1'","'$CORE_PATH'","'$NO_GAP_BED'","'$VERACODE'",$1,$2"\n""sleep 1s"}'

##################
##### CODING #####
##################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.04_EXTRACT_VCF_CODING_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_VCF_CODING_.log",\
"'$SCRIPT_DIR'""/Q.04_EXTRACT_VCF_CODING.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.05_EXTRACT_VCF_CODING_PASS_VARIANT_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_VCF_CODING_PASS_VARIANT.log",\
"'$SCRIPT_DIR'""/Q.05_EXTRACT_VCF_CODING_PASS_VARIANT.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

######################
##### CODING SNV #####
######################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.06_EXTRACT_SNV_CODING_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_SNV_CODING.log",\
"'$SCRIPT_DIR'""/Q.06_EXTRACT_SNV_CODING.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.07_EXTRACT_SNV_CODING_PASS_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_SNV_CODING_PASS.log",\
"'$SCRIPT_DIR'""/Q.07_EXTRACT_SNV_CODING_PASS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.07-A.01_TITV_CODING_"$2"_"$1,\
"-hold_jid","Q.07_EXTRACT_SNV_CODING_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".TITV_CODING.log",\
"'$SCRIPT_DIR'""/Q.07-A.01_TITV_CODING.sh",\
"'$SAMTOOLS_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.07-A.02_EXTRACT_CODING_KNOWN_"$2"_"$1,\
"-hold_jid","Q.07_EXTRACT_SNV_CODING_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_CODING_KNOWN.log",\
"'$SCRIPT_DIR'""/Q.07-A.02_EXTRACT_CODING_KNOWN.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$DBSNP_129'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.07-A.02-A.01_TITV_CODING_KNOWN_"$2"_"$1,\
"-hold_jid","Q.07-A.02_EXTRACT_CODING_KNOWN_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".TITV_CODING_KNOWN.log",\
"'$SCRIPT_DIR'""/Q.07-A.02-A.01_TITV_CODING_KNOWN.sh",\
"'$SAMTOOLS_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.07-A.03_EXTRACT_CODING_NOVEL_"$2"_"$1,\
"-hold_jid","Q.07_EXTRACT_SNV_CODING_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_CODING_NOVEL_.log",\
"'$SCRIPT_DIR'""/Q.07-A.03_EXTRACT_CODING_NOVEL.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$DBSNP_129'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.07-A.03-A.01_TITV_CODING_NOVEL_"$2"_"$1,\
"-hold_jid","Q.07_EXTRACT_SNV_CODING_PASS_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".TITV_CODING_NOVEL.log",\
"'$SCRIPT_DIR'""/Q.07-A.03-A.01_TITV_CODING_NOVEL.sh",\
"'$SAMTOOLS_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'

##############################
##### WHOLE GENOME INDEL #####
##############################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.08_EXTRACT_INDEL_WG_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_INDEL_WG.log",\
"'$SCRIPT_DIR'""/Q.08_EXTRACT_INDEL_WG.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.09_EXTRACT_INDEL_WG_PASS_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_INDEL_WG_PASS.log",\
"'$SCRIPT_DIR'""/Q.09_EXTRACT_INDEL_WG_PASS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

########################
##### CODING INDEL #####
########################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.10_EXTRACT_INDEL_CODING_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_INDEL_CODING.log",\
"'$SCRIPT_DIR'""/Q.10_EXTRACT_INDEL_CODING.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.11_EXTRACT_INDEL_CODING_PASS_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_INDEL_CODING_PASS.log",\
"'$SCRIPT_DIR'""/Q.11_EXTRACT_INDEL_CODING_PASS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

##############################
##### WHOLE GENOME MIXED #####
##############################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.12_EXTRACT_MIXED_WG_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_MIXED_WG.log",\
"'$SCRIPT_DIR'""/Q.12_EXTRACT_MIXED_WG.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.13_EXTRACT_MIXED_WG_PASS_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_MIXED_WG_PASS.log",\
"'$SCRIPT_DIR'""/Q.13_EXTRACT_MIXED_WG_PASS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'


########################
##### CODING MIXED #####
########################

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.14_EXTRACT_MIXED_CODING_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_MIXED_CODING.log",\
"'$SCRIPT_DIR'""/Q.14_EXTRACT_MIXED_CODING.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

sed 's/\r//g; s/,/\t/g' $SAMPLE_SHEET \
| awk 'NR>1' \
| sort -k 8,8 \
| awk 'BEGIN {OFS="\t"} {print $1,$8,$12}' \
| sort -k 1,1 -k 2,2 \
| uniq \
| awk '{split($2,smtag,"[@-]"); \
print "qsub","-N","Q.15_EXTRACT_MIXED_CODING_PASS_"$2"_"$1,\
"-hold_jid","P.01_APPLY_VQSR_INDEL_"$2"_"$1,\
"-o","'$CORE_PATH'/"$1"/LOGS/"$2"_"$1".EXTRACT_MIXED_CODING_PASS.log",\
"'$SCRIPT_DIR'""/Q.15_EXTRACT_MIXED_CODING_PASS.sh",\
"'$JAVA_1_7'","'$GATK_DIR'","'$CORE_PATH'","'$CODING_BED'","'$CODING_BED_MT'","'$GATK_KEY'",$1,$2,$3"\n""sleep 1s"}'

##################################################################################
##################################################################################
##################################################################################

# # RUN ANEUPLOIDY_CHECK AFTER CODING PLUS 10 BP FLANKS FINISHES
#
# awk 'BEGIN {OFS="\t"} {print $1,$19,$8}' \
# ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt \
# | sort -k 1,1 -k 2,2 -k 3,3 \
# | uniq \
# | awk '{split($3,smtag,"[@-]"); \
# print "qsub","-N","H.03-A.01_DOC_CHROM_DEPTH_"$3"_"$1,\
# "-hold_jid","H.03_DOC_CODING_10bpFLANKS_"$3"_"$1,\
# "-o","'$CORE_PATH'/"$1"/"$2"/"$3"/LOGS/"$3"_"$1".ANEUPLOIDY_CHECK.log",\
# "'$SCRIPT_DIR'""/H.03-A.01_CHROM_DEPTH.sh",\
# "'$CORE_PATH'","'$CYTOBAND_BED'","'$DATAMASH_DIR'","'$BEDTOOLS_DIR'",$1,$2,$3"\n""sleep 1s"}'
#
#
# ###################################################
# ### RUN VERIFYBAM ID PER CHROMOSOME - VITO ########
# ###################################################
#
# CREATE_SAMPLE_INFO_ARRAY_VERIFY_BAM ()
# {
# SAMPLE_INFO_ARRAY_VERIFY_BAM=(`awk '$8=="'$SAMPLE'" {print $1,$19,$8,$12,$14}' ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt`)
# }
#
# CALL_SELECT_VERIFY_BAM ()
# {
# echo \
# qsub \
# -N H.09_SELECT_VERIFYBAMID_VCF_${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}_chr$CHROMOSOME \
# -hold_jid G.01_FINAL_BAM_${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]} \
# -o $CORE_PATH/${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}/${SAMPLE_INFO_ARRAY_VERIFY_BAM[1]}/${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}/LOGS/${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}.SELECT_VERIFYBAMID_chr$CHROMOSOME.log \
# $SCRIPT_DIR/H.09_SELECT_VERIFYBAMID_VCF_CHR.sh \
# $JAVA_1_7 $GATK_DIR $CORE_PATH $VERIFY_VCF \
# ${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[1]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[3]} \
# ${SAMPLE_INFO_ARRAY_VERIFY_BAM[4]} $CHROMOSOME
# }
#
# CALL_VERIFYBAMID ()
# {
# echo \
# qsub \
# -N H.09-A.01_VERIFYBAMID_${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}_chr$CHROMOSOME \
# -hold_jid H.09_SELECT_VERIFYBAMID_VCF_${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}_chr$CHROMOSOME \
# -o $CORE_PATH/${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}/${SAMPLE_INFO_ARRAY_VERIFY_BAM[1]}/${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}/LOGS/${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}.VERIFYBAMID_chr$CHROMOSOME.log \
# $SCRIPT_DIR/H.09-A.01_VERIFYBAMID_CHR.sh \
# $CORE_PATH $VERIFY_DIR \
# ${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[1]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]} \
# $CHROMOSOME
# }
#
# for SAMPLE in $(awk 'BEGIN {FS=","} NR>1 {print $8}' $SAMPLE_SHEET | sort | uniq );
# do
# CREATE_SAMPLE_INFO_ARRAY_VERIFY_BAM
# 	for CHROMOSOME in {1..22}
# 		do
# 		CALL_SELECT_VERIFY_BAM
# 		echo sleep 1s
# 		CALL_VERIFYBAMID
# 		echo sleep 1s
# 	done
# done
#
# #####################################################
# ### JOIN THE PER CHROMOSOME VERIFYBAMID REPORTS #####
# #####################################################
#
# BUILD_HOLD_ID_PATH_CAT_VERIFYBAMID_CHR ()
# {
# 	for PROJECT in $(awk 'BEGIN {FS=","} NR>1 {print $1}' $SAMPLE_SHEET | sort | uniq )
# 	do
# 	HOLD_ID_PATH="-hold_jid "
# 	for CHROMOSOME in {{1..22},{X,Y}};
#  	do
#  		HOLD_ID_PATH=$HOLD_ID_PATH"H.09-A.01_VERIFYBAMID_"${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}"_"${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}"_"chr$CHROMOSOME","
#  	done
#  done
# }
#
#  CAT_VERIFYBAMID_CHR ()
#  {
# echo \
# qsub \
# -N H.09-A.01-A.01_JOIN_VERIFYBAMID_${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]} \
# $HOLD_ID_PATH \
# -o $CORE_PATH/${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}/${SAMPLE_INFO_ARRAY_VERIFY_BAM[1]}/${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}/LOGS/${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}_${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]}.CAT_VERIFYBAMID_CHR.log \
# $SCRIPT_DIR/H.09-A.01-A.01_CAT_VERIFYBAMID_CHR.sh \
# $CORE_PATH \
# ${SAMPLE_INFO_ARRAY_VERIFY_BAM[0]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[1]} ${SAMPLE_INFO_ARRAY_VERIFY_BAM[2]}
#  }
#
# for SAMPLE in $(awk 'BEGIN {FS=","} NR>1 {print $8}' $SAMPLE_SHEET | sort | uniq );
#  do
#  	CREATE_SAMPLE_INFO_ARRAY_VERIFY_BAM
# 	BUILD_HOLD_ID_PATH_CAT_VERIFYBAMID_CHR
# 	CAT_VERIFYBAMID_CHR
# 	echo sleep 1s
#  done
#

#### DO NOT USE...BUT GOOD FOR A REFERENCE LATER ####

# ############################################################################################################
# ##### DO PER CHROMOSOME VARIANT TO TABLE FOR COHORT ########################################################
# ############################################################################################################
#
# CREATE_FAMILY_ONLY_ARRAY ()
# {
# FAMILY_ONLY_ARRAY=(`awk '$19=="'$FAMILY'" {print $1,$19,$12,$17}' ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt`)
# }
#
# CALL_VARIANT_TO_TABLE_COHORT_ALL_SITES ()
# {
# echo \
# qsub \
# -N P.01-A.02_VARIANT_TO_TABLE_COHORT_ALL_SITES_${FAMILY_ONLY_ARRAY[1]}_${FAMILY_ONLY_ARRAY[0]}_$CHROMOSOME \
# -hold_jid P.01_VARIANT_ANNOTATOR_${FAMILY_ONLY_ARRAY[1]}_${FAMILY_ONLY_ARRAY[0]}_$CHROMOSOME \
# -o $CORE_PATH/${FAMILY_ONLY_ARRAY[0]}/${FAMILY_ONLY_ARRAY[1]}/LOGS/${FAMILY_ONLY_ARRAY[1]}_${FAMILY_ONLY_ARRAY[0]}.VARIANT_TO_TABLE_COHORT_ALL_SITES_$CHROMOSOME.log \
# $SCRIPT_DIR/P.01-A.02_VARIANT_TO_TABLE_COHORT_ALL_SITES_CHR.sh \
# $JAVA_1_7 $GATK_DIR $CORE_PATH \
# ${FAMILY_ONLY_ARRAY[0]} ${FAMILY_ONLY_ARRAY[1]} ${FAMILY_ONLY_ARRAY[2]} $CHROMOSOME
# }
#
# for FAMILY in $(awk 'BEGIN {FS="\t"} {print $1}' $PED_FILE | sort | uniq );
# do
# CREATE_FAMILY_ONLY_ARRAY
# 	for CHROMOSOME in {{1..22},{X,Y}}
# 		do
# 		CALL_VARIANT_TO_TABLE_COHORT_ALL_SITES
# 		echo sleep 1s
# 		done
# 	done
#
# ################################################################################################################
# ##### GATHER PER CHROMOSOME VARIANT TO TABLE FOR COHORT ########################################################
# ################################################################################################################
#
# BUILD_HOLD_ID_PATH_VARIANT_TO_TABLE_COHORT_GATHER ()
# {
# 	for PROJECT in $(awk 'BEGIN {FS=","} NR>1 {print $1}' $SAMPLE_SHEET | sort | uniq )
# 	do
# 	HOLD_ID_PATH="-hold_jid "
# 	for CHROMOSOME in {{1..22},{X,Y}};
#  	do
#  		HOLD_ID_PATH=$HOLD_ID_PATH"P.01-A.02_VARIANT_TO_TABLE_COHORT_ALL_SITES_"$FAMILY"_"$PROJECT"_"$CHROMOSOME","
#  	done
#  done
# }
#
# CALL_VARIANT_TO_TABLE_COHORT_GATHER ()
# {
# echo \
# qsub \
# -N T.18_VARIANT_TO_TABLE_COHORT_ALL_SITES_GATHER_${FAMILY_INFO_ARRAY[2]}_${FAMILY_INFO_ARRAY[0]} \
#  ${HOLD_ID_PATH} \
#  -o $CORE_PATH/${FAMILY_INFO_ARRAY[0]}/${FAMILY_INFO_ARRAY[2]}/LOGS/${FAMILY_INFO_ARRAY[2]}_${FAMILY_INFO_ARRAY[0]}.VARIANT_TO_TABLE_COHORT_ALL_SITES_GATHER.log \
#  $SCRIPT_DIR/T.18_VARIANT_TO_TABLE_COHORT_ALL_SITES_GATHER.sh \
#  $JAVA_1_7 $GATK_DIR $CORE_PATH \
#  ${FAMILY_INFO_ARRAY[0]} ${FAMILY_INFO_ARRAY[2]} ${FAMILY_INFO_ARRAY[3]}
# }
#
# for FAMILY in $(awk 'BEGIN {FS="\t"} {print $19}' ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt | sort | uniq)
#  do
# 	BUILD_HOLD_ID_PATH_VARIANT_TO_TABLE_COHORT_GATHER
# 	CREATE_FAMILY_INFO_ARRAY
# 	CALL_VARIANT_TO_TABLE_COHORT_GATHER
# 	echo sleep 1s
#  done
#
# ##############################################################################################################
# ## BGZIP INITIAL JOINT CALLED VCF TABLE ######################################################################
# ##############################################################################################################
#
# awk 'BEGIN {OFS="\t"} {print $1,$19}' \
# ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt \
# | sort -k 1,1 -k 2,2 \
# | uniq \
# | awk '{print "qsub","-N","T.18-A.01_VARIANT_TO_TABLE_BGZIP_COHORT_ALL_SITES_"$2"_"$1,\
# "-hold_jid","T.18_VARIANT_TO_TABLE_COHORT_ALL_SITES_GATHER_"$2"_"$1,\
# "-o","'$CORE_PATH'/"$1"/"$2"/LOGS/"$2"_"$1".VARIANT_TO_TABLE_BGZIP_COHORT_ALL_SITES.log",\
# "'$SCRIPT_DIR'""/T.18-A.01_VARIANT_TO_TABLE_BGZIP_COHORT_ALL_SITES.sh",\
# "'$TABIX_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'
#
# ##############################################################################################################
# ## TABIX INDEX INITIAL JOINT CALLED VCF TABLE ################################################################
# ##############################################################################################################
#
# awk 'BEGIN {OFS="\t"} {print $1,$19}' \
# ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt \
# | sort -k 1,1 -k 2,2 \
# | uniq \
# | awk '{print "qsub","-N","T.18-A.01-A.01_VARIANT_TO_TABLE_TABIX_COHORT_ALL_SITES_"$2"_"$1,\
# "-hold_jid","T.18-A.01_VARIANT_TO_TABLE_BGZIP_COHORT_ALL_SITES_"$2"_"$1,\
# "-o","'$CORE_PATH'/"$1"/"$2"/LOGS/"$2"_"$1".VARIANT_TO_TABLE_TABIX_COHORT_ALL_SITES.log",\
# "'$SCRIPT_DIR'""/T.18-A.01-A.01_VARIANT_TO_TABLE_TABIX_COHORT_ALL_SITES.sh",\
# "'$TABIX_DIR'","'$CORE_PATH'",$1,$2"\n""sleep 1s"}'
#
# ######### FINISH UP #################
#
# ### QC REPORT PREP ###
#
# awk 'BEGIN {OFS="\t"} {print $1,$19,$8,$20,$21,$22,$23}' \
# ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt \
# | sort -k 1,1 -k 2,2 -k 3,3 \
# | uniq \
# | awk 'BEGIN {FS="\t"}
# {print "qsub","-N","X.01-QC_REPORT_PREP_"$1"_"$3,\
# "-hold_jid","T.06-2-A.01-A.01-A.01_VARIANT_TO_TABLE_TABIX_SAMPLE_ALL_SITES_"$3"_"$2"_"$1,\
# "-o","'$CORE_PATH'/"$1"/LOGS/"$3"_"$1".QC_REPORT_PREP.log",\
# "'$SCRIPT_DIR'""/X.01-QC_REPORT_PREP.sh",\
# "'$SAMTOOLS_DIR'","'$CORE_PATH'","'$DATAMASH_DIR'",$1,$2,$3,$4,$5,$6,$7"\n""sleep 1s"}'
#
# ### END PROJECT TASKS ###
#
# awk 'BEGIN {OFS="\t"} {print $1,$8}' \
# ~/CGC_PIPELINE_TEMP/$MANIFEST_PREFIX.$PED_PREFIX.join.txt \
# | sort -k 1,1 -k 2,2 \
# | uniq \
# | $DATAMASH_DIR/datamash -s -g 1 collapse 2 \
# | awk 'BEGIN {FS="\t"}
# gsub (/,/,",X.01-QC_REPORT_PREP_"$1"_",$2) \
# {print "qsub","-N","X.01-X.01-END_PROJECT_TASKS_"$1,\
# "-hold_jid","X.01-QC_REPORT_PREP_"$1"_"$2,\
# "-o","'$CORE_PATH'/"$1"/LOGS/"$1".END_PROJECT_TASKS.log",\
# "'$SCRIPT_DIR'""/X.01-X.01-END_PROJECT_TASKS.sh",\
# "'$CORE_PATH'","'$DATAMASH_DIR'",$1"\n""sleep 1s"}'

### kEY FOR BLAH ###
#     1  Project DDL_170323_HJH3HBCXY_CGCDev13D14B
#     2  FCID    HJH3HBCXY
#     3  Lane    1
#     4  Index   ACAGCAGA
#     5  Platform        ILLUMINA
#     6  Library_Name    D01_NA10925_D08
#     7  Date    3/23/2017
#     8  SM_Tag  NA10925-1
#     9  Center  Johns_Hopkins_DNA_Diagnostic_Lab
#    10  Description     HiSeq2500_RapidRun
#    11  Seq_Exp_ID      HJH3HBCXY_1_ACAGCAGA_D01_NA10925_D08
#    12  Genome_Ref      /isilon/sequencing/GATK_resource_bundle/bwa_mem_0.7.5a_ref/human_g1k_v37_decoy.fasta
#    13  Operator        ABR
#    14  Extra_VCF_Filter_Params -2
#    15  TS_TV_BED_File  /isilon/sequencing/data/Work/BED/Production_BED_files/TsTv_BED_File_Agilent_ClinicalExome_S06588914_OnExon_merged_021015_noCHR.bed
#    16  Baits_BED_File  /isilon/sequencing/data/Work/BED/Production_BED_files/ALLBED_BED_File_Agilent_ClinicalExome_S06588914_ALLBed_merged_021015_noCHR.bed
#    17  Targets_BED_File        /isilon/sequencing/data/Work/BED/Production_BED_files/Targets_BED_File_Agilent_ClinicalExome_S06588914_OnTarget_merged_noCHR_013015.bed
#    18  KNOWN_SITES_VCF /isilon/sequencing/GATK_resource_bundle/2.8/b37/dbsnp_138.b37.vcf
#    19  /isilon/sequencing/GATK_resource_bundle/2.2/b37/1000G_phase1.indels.b37.vcf;/isilon/sequencing/GATK_resource_bundle/2.2/b37/Mills_and_1000G_gold_standard.indels.b37.vcf
#######


###### SAMPLE MANIFEST KEY...NOT SURE WHAT I AM GOING TO END UP DOING HERE ######

# PROJECT=$1 # the Seq Proj folder name. 1st column in sample manifest
# FLOWCELL=$2 # flowcell that sample read group was performed on. 2nd column of sample manifest
# LANE=$3 # lane of flowcell that sample read group was performed on. 3rd column of the sample manifest
# INDEX=$4 # sample barcode. 4th column of the sample manifest
# PLATFORM=$5 # type of sequencing chemistry matching SAM specification. 5th column of the sample manifest.
# LIBRARY_NAME=$6 # library group of the sample read group.
# 								# Used during Marking Duplicates to determine if molecules are to be considered as part of the same library or not
# 								# 6th column of the sample manifest
# RUN_DATE=$7 # should be the run set up date to match the seq run folder name, but it has been arbitrarily populated. field X of manifest.
# SM_TAG=$8 # sample ID. sample name for all files, etc. field X of manifest
# CENTER=$9 # the center/funding mechanism. field X of manifest.
# DESCRIPTION=${10} # Generally we use to denote the sequencer setting (e.g. rapid run). field X of manifest.
# REF_GENOME=${11} # the reference genome used in the analysis pipeline. field X of manifest.
# TI_TV_BED=${12} # populated from sample manifest. where ucsc coding exons overlap with bait and target bed files
# BAIT_BED=${13} # populated from sample manifest. a super bed file incorporating bait, target, padding and overlap with ucsc coding exons.
# 								# Used for limited where to run base quality score recalibration on where to create gvcf files.
# TARGET_BED=${14} # populated from sample manifest. bed file acquired from manufacturer of their targets. field X of sample manifest.
# DBSNP=${15} # populated from sample manifest. used to annotate ID field in VCF file. masking in base call quality score recalibration.
# KNOWN_INDEL_1=${16} # populated from sample manifest. used for BQSR masking, sensitivity in local realignment.
# KNOWN_INDEL_2=${17} # populated from sample manifest. used for BQSR masking, sensitivity in local realignment.
#
# RIS_ID=${SM_TAG%@*} # no longer needed when using PHOENIX. used to needed to break out the "@" in the sm tag so it wouldn't break things.
# BARCODE_2D=${SM_TAG#*@} # no longer needed when using PHOENIX. used to needed to break out the "@" in the sm tag so it wouldn't break things.
#
####################################################################################
