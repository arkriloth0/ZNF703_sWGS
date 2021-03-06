#!/bin/bash
#
#SBATCH --job-name=g1k_qdnaseq
#SBATCH --time=1-0
#SBATCH --mem=32G
#SBATCH -o %A_%a.g1k_qdnaseq.out
#SBATCH -e %A_%a.g1k_qdnaseq.err

IDS=$1
MAP=$2

SAMPLE=`head -n $SLURM_ARRAY_TASK_ID $IDS | tail -n 1`

# bwa-indexed hg38 analysis set
HG38_REF=/scratcha/cclab_tmp/lui01/hg38/analysis_set_index_bwa/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna

#Assuming 40-core CPU
for FASTQ in `grep ^$SAMPLE $MAP | cut -f 2`
do
  trim_galore --cores 40 --hardtrim5 50 $FASTQ
  BFASTQ=${FASTQ%.fastq.gz}
  COMBINED=${SAMPLE}_${BFASTQ}
  bwa aln -t 40 -n 2 -q 40 $HG38_REF $BFASTQ.50bp_5prime.fq.gz > $COMBINED.sai
  bwa samse $HG38_REF $COMBINED.sai $BFASTQ.50bp_5prime.fq.gz | samtools view -hb -@ 39 | samtools sort -@ 39 - > ${COMBINED}.bam
  samtools index -@ 39 $COMBINED.bam
done

samtools merge  -@ 39 $SAMPLE.bam ${SAMPLE}_*.bam
samtools index -@ 39 $SAMPLE.bam