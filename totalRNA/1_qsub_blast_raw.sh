#!/bin/bash
#$ -S /bin/bash
#$ -pe make 30
#$ -m abe
#$ -cwd

CMDNAME=`basename $0`
if [ $# -ne 3 ]; then
  echo "Usage: $CMDNAME samplename minimum_length e-value"
  exit 1
fi

# 1. fastq to fasta
export PATH=$PATH:$HOME/local/bin
seqkit fq2fa $HOME/total_RNA/data/$1_karect_trimmed.fastq -o $HOME/total_RNA/data/$1_karect_trimmed.fasta

# 2. picking up longer reads (> 200bp)
cd $HOME/total_RNA/data
mkdir files_$2
export PATH=$PATH:$HOME/local/bin
seqkit seq -m $2 $1_karect_trimmed.fasta > ./files_$2/$1_karect_trimmed_$2.fasta 

# 3. annotation BLASTn
#cd Data
blastn -db ../BLASTDB/slv123_SSU_99_trunc \
    -query $HOME/total_RNA/data/files_$2/$1_karect_trimmed_$2.fasta \
    -evalue $3 -num_alignments 15 \
    -outfmt 6 -num_threads 30 -out $1_$2_$3
