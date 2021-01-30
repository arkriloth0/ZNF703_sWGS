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
hg38_ref=

for FASTQ in `grep ^$SAMPLE $MAP | cut -f 2`
do
  trim_galore --hardtrim5 50 $FASTQ
  BFASTQ=${FASTQ%.fastq.gz}
  COMBINED=${SAMPLE}_${BFASTQ}
  bwa aln -n 2 -q 40 $hg38_ref $BFASTQ.50bp_5prime.fq.gz > $COMBINED.sai
  bwa samse $hg38_ref $COMBINED.sai $BFASTQ.50bp_5prime.fq.gz | samtools view -hb | samtools sort - > ${COMBINED}.bam
  samtools index $COMBINED.bam
done

samtools merge $SAMPLE.bam ${SAMPLE}_*.bam
samtools index $SAMPLE.bam