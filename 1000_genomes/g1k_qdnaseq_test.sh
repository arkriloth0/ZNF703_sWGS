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
  echo $SAMPLE
  echo $FASTQ
done