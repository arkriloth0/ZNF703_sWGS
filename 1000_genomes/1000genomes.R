urlroot <- "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/historical_data/former_toplevel"
g1k <- read.table(file.path(urlroot, "sequence.index"), header=TRUE, sep="\t", as.is=TRUE, fill=TRUE)

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
g1k$fileName <- basename(g1k$FASTQ_FILE)

#setup for below
seqroot = "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/"
sourceFile <- file.path(seqroot, g1k[, "FASTQ_FILE"])
setwd("./1000_genomes")

#write list of download URLs
write.table(sourceFile,"g1k_qdnaseq.txt",col.names=F, quote=F, row.names=F, sep="\t")

#directly download files from URLs
#for (i in rownames(g1k)) { sourceFile <- file.path(seqroot, g1k[i, "FASTQ_FILE"])
#destFile <- g1k[i, "fileName"]
#if (!file.exists(destFile))
#  download.file(sourceFile, destFile, mode="wb")
#}

#generate sample file map
x = subset(g1k, select=c(SAMPLE_NAME, fileName))
write.table(x, "sample_file_map.txt", col.names=F, quote=F, row.names=F, sep="\t")
