#NOT RECOMMENDED TO USE THIS SCRIPT
#uses new data from 1000 genomes project, instead of only the historical data used in the original QDNAseq package

library(RCurl)
library(data.table)
library(tidyverse)
library(QDNAseq)
library(Biobase)

#download 1000 genomes project sequence index file
url <- "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/1000genomes.sequence.index"
setwd("./1000_genomes")
download.file(url, basename(url))


#read index table
g1k <- fread(file = "1000genomes.sequence.index", header = TRUE, sep = "\t", fill = TRUE, skip = "FASTQ_ENA_PATH	MD5")
g1k <- rename(g1k, FASTQ_ENA_PATH = "#FASTQ_ENA_PATH")
setwd("..")


# keep cases that are Illumina, low coverage, single-read, and not withdrawn
g1k <- g1k[g1k$INSTRUMENT_PLATFORM == "ILLUMINA", ]
g1k <- g1k[g1k$ANALYSIS_GROUP == "low coverage", ]
g1k <- g1k[g1k$LIBRARY_LAYOUT == "SINGLE", ]
g1k <- g1k[g1k$WITHDRAWN == 0, ]

# keep cases with read lengths of at least 50 bp
g1k <- g1k[!g1k$BASE_COUNT %in% c("not available", ""), ]
g1k$BASE_COUNT <- as.numeric(g1k$BASE_COUNT)
g1k$READ_COUNT <- as.integer(g1k$READ_COUNT)
g1k$readLength <- g1k$BASE_COUNT / g1k$READ_COUNT
g1k <- g1k[g1k$readLength > 50, ]

# keep samples with a minimum of one million reads
readCountPerSample <- aggregate(g1k$READ_COUNT, by=list(sample=g1k$SAMPLE_NAME), FUN=sum)
g1k <- g1k[g1k$SAMPLE_NAME %in% readCountPerSample$sample[readCountPerSample$x >= 1e6], ]
g1k$fileName <- basename(g1k$FASTQ_ENA_PATH)

# download FASTQ files
for (i in rownames(g1k)) {
  sourceFile <- file.path(g1k[i, "FASTQ_ENA_PATH"])
  destFile <- g1k[i, "fileName"]
  if (!file.exists(destFile))
  download.file(sourceFile, destFile, mode="wb")
}