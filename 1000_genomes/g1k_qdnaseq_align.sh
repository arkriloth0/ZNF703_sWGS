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
HG38_REF=/scratcha/cclab_tmp/lui01/hg38/analysis_set_index_bwa/GCA_000001405.15_GRCh38_full_plus_hs38d1_analysis_set.fna.gz

#Assuming 20-core CPU
for FASTQ in `grep ^$SAMPLE $MAP | cut -f 2`
do
  trim_galore --cores 20 --hardtrim5 50 $FASTQ
  BFASTQ=${FASTQ%.fastq.gz}
  COMBINED=${SAMPLE}_${BFASTQ}
  bwa aln -t 20 -n 2 -q 40 $HG38_REF $BFASTQ.50bp_5prime.fq.gz > $COMBINED.sai
  bwa samse $HG38_REF $COMBINED.sai $BFASTQ.50bp_5prime.fq.gz | samtools view -hb -@ 19 | samtools sort -@ 19 - > ${COMBINED}.bam
  samtools index -@ 19 $COMBINED.bam
done

samtools merge  -@ 19 $SAMPLE.bam ${SAMPLE}_*.bam
samtools index -@ 19 $SAMPLE.bam