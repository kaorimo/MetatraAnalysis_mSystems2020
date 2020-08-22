#!/bin/bash
#$ -S /bin/bash
#$ -pe make 30
#$ -m abe
#$ -cwd

CPU=30
DIR=$HOME/metatra

cd $DIR/fastq
mv ./IonXpressRNA_005_R_2017_03_22_11_15_33_user_KKK-322-motoki_RNA_sample.fastq ./insitu_4_1_2.fastq
mv ./IonXpressRNA_006_R_2017_03_22_15_50_11_user_KKK-323-motoki_RNA_sample.fastq ./insitu_8_3.fastq
mv ./IonXpressRNA_007_R_2017_03_28_11_05_11_user_KKK-324-motoki_RNA_sample.fastq ./onboard_2_1_2.fastq
mv ./IonXpressRNA_008_R_2017_03_29_11_06_57_user_KKK-325-motoki_RNA_sample.fastq ./onboard_10_1_2.fastq

SAMPLE=("insitu_4_1_2" "insitu_8_3" "onboard_2_1_2" "onboard_10_1_2")

### Quarity filtering
for i in `seq 0 3`; do

# ERROR CORRECTION - karect-1.0 -
mkdir $DIR/karect
export karect=$HOME/biotools/karect; \
$karect/karect -correct -celltype=haploid -matchtype=edit \
    -threads=$CPU \
    -inputfile=$DIR/fastq/${SAMPLE[$i]}.fastq -resultdir=$DIR/karect

# PRINSEQ - prinseq-0.20.4 - 26
mkdir $DIR/prinseq
export PRINSEQ=$HOME/biotools/prinseq-lite-0.20.4; \
$PRINSEQ/prinseq-lite.pl -fastq ./karect_${SAMPLE[$i]}.fastq \
    -min_len 50 -trim_qual_left 26 -trim_qual_right 26 -trim_qual_window 10 \
    -out_good $DIR/prinseq/${SAMPLE[$i]}_karect26_trimmed \
    -log $DIR/prinseq/${SAMPLE[$i]}_karect26_trimmed.log

done


### Assemble - TRINITY - >300bp
cd $DIR
export TRINITY_HOME=$HOME/biotools/trinityrnaseq-Trinity-v2.3.2; \
 export PATH=$PATH:$HOME/biotools/samtools-1.3.1:$HOME/biotools/bowtie2-2.2.9:$HOME/biotools/samtools-bcftools-htslib-1.0_x64-linux/bin:$HOME/biotools/RSEM-1.2.30:$HOME/biotools//bowtie-1.1.2

$TRINITY_HOME/Trinity --seqType fq \
    --single $HOME/prinseq/*_karect26_trimmed.fastq \
    --min_contig_length 300 \
    --CPU 16 --max_memory 90G \
    --output trinity_karect_26_300

$HOME/biotools/gc_contentSkew.pl -if $HOME/trinity_karect_26_300/Trinity.fasta  -p gc; \
 cut -f1,2,3,4 outgc | awk '{FS="\t"}$2 > 200{print}' | sort -rnk2 | perl -F'\t' -anle 'BEGIN{$info={}; $info->{max}= 0}; $info->{count}++; $info->{sum}+= $F[1]; $info->{n50}->{$F[1]}= $info->{sum}; $info->{max}= $F[1] if($info->{max} < $F[1]); push @{$info->{len}}, $F[1]; $info->{GC}+= $F[3]; END{print "COUNT: $info->{count}"; print "SUM: $info->{sum}"; print "MAX: $info->{max}"; @values=grep{$info->{n50}->{$_} > $info->{sum}/2}@{$info->{len}}; print "N50: $values[0]"; print "@{$info->{len}}[0..4]"; print "GC: ".($info->{GC}/$info->{count})}'


### CDS - Transdecoder - >100AA
mkdir $DIR/Transdecoder_karect_26_300
cd $DIR/Transdecoder_karect_26_300
# extract the long open reading frames  ## > 100 aa
$HOME/biotools/TransDecoder-2.0.1/TransDecoder.LongOrfs -t $DIR/trinity_karect_26_300/Trinity.fasta 
# predict the likely coding regions
$HOME/biotools/TransDecoder-2.0.1/TransDecoder.Predict -t $DIR/trinity_karect_26_300/Trinity.fasta


### Mapping and abundance estimation
for i in `seq 0 3`; do

export TRINITY_HOME=$HOME/biotools/trinityrnaseq-Trinity-v2.3.2; \
 export PATH=$PATH:$HOME/biotools/samtools-1.3.1:$HOME/biotools/bowtie2-2.2.9:/$HOME/biotools/samtools-bcftools-htslib-1.0_x64-linux/bin:$HOME/biotools/RSEM-1.2.30:$HOME/biotools/bowtie-1.1.2

$TRINITY_HOME/util/align_and_estimate_abundance.pl \
    --seqType fq \
    --est_method RSEM --aln_method bowtie2 --thread_count 8 --trinity_mode \
    --transcripts $HOME/trinity_karect_26_300/Trinity.fasta \
    --single $HOME/prinseq/${SAMPLE[$i]}_karect26_trimmed.fastq \
    --output_dir mapping_karect26_300 \
    --output_prefix ${SAMPLE[$i]}

## Number of Mapped reads
$HOME/biotools/samtools-bcftools-htslib-1.0_x64-linux/bin/samtools view -F 0x40 $DIR/mapping_karect26_300/${SAMPLE[$i]}.bowtie2.bam | cut -f 1 | sort | uniq | wc -l

done
