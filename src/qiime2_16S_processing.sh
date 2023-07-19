#!/bin/bash
set -x
set -e
set -u

source activate qiime2-2021.4

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path data/fastq
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path output/qiime2_16S/demux.qza
qiime cutadapt trim-paired \
  --i-demultiplexed-sequences output/qiime2_16S/demux.qza \
  --p-cores 30 \
  --p-front-f ACTCCTACGGGAGGCAGCAG \
  --p-front-r GGACTACHVGGGTWTCTAAT \
  --p-adapter-f ATTAGAWACCCBDGTAGTCC \
  --p-adapter-r CTGCTGCCTCCCGTAGGAGT \
  --verbose \
  --o-trimmed-sequences qoutput/qiime2_16S/trimmed-reads.qza
qiime tools export --output-path output/qiime2_16S/trimmed_reads \
  --input-path output/qiime2_16S/trimmed-reads.qza 
qiime demux summarize \
  --i-data output/qiime2_16S/trimmed-reads.qza \
  --o-visualization output/qiime2_16S/demux.qzv
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs output/qiime2_16S/trimmed-reads.qza \
  --o-table output/qiime2_16S/table-dada2 \
  --o-representative-sequences output/qiime2_16S/rep-seqs-dada2 \
  --o-denoising-stats output/qiime2_16S/denoising-stats\
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 271 \
  --p-trunc-len-r 220 \
  --p-n-threads 30  
qiime feature-table summarize \
  --i-table output/qiime2_16S/table-dada2.qza \
  --o-visualization output/qiime2_16S/table-dada2.qzv \
  --m-sample-metadata-file metadata.tsv
qiime diversity alpha-rarefaction \
  --i-table output/qiime2_16S/table-dada2.qza \
  --p-max-depth 186708 \
  --p-steps 100 \
  --o-visualization output/qiime2_16S/alpha-rarefaction.qzv
qiime diversity alpha-rarefaction \
  --i-table output/qiime2_16S/table-dada2.qza \
  --p-max-depth 2000 \
  --p-steps 10 \
  --o-visualization output/qiime2_16S/alpha-rarefaction_zoom.qzv
qiime alignment mafft \
  --i-sequences rep-seqs-dada2.qza \
  --o-alignment aligned-rep-seqs.qza
qiime tools export \
  --input-path output/qiime2_16S/rep-seqs-dada2.qza \
  --output-path output/qiime2_16S/exported_aligned-rep-seqs  
qiime alignment mask \
  --i-alignment output/qiime2_16S/aligned-rep-seqs.qza \
  --o-masked-alignment output/qiime2_16S/masked-aligned-rep-seqs.qza
qiime phylogeny fasttree \
  --i-alignment output/qiime2_16S/masked-aligned-rep-seqs.qza \
  --o-tree output/qiime2_16S/unrooted-tree.qza
qiime tools export \
  --input-path output/qiime2_16S/unrooted-tree.qza \
  --output-path output/qiime2_16S/exported_unrooted-tree.qza 
qiime phylogeny midpoint-root \
  --i-tree output/qiime2_16S/unrooted-tree.qza \
  --o-rooted-tree output/qiime2_16S/rooted-tree.qza 
mkdir -p output/qiime2_16S/classifier_training
wget -P output/qiime2_16S/classifier_training https://data.qiime2.org/2021.8/common/silva-138-99-seqs.qza
wget -P output/qiime2_16S/classifier_training https://data.qiime2.org/2021.8/common/silva-138-99-tax.qza
## For is 338F
## Rev is 806r Original (Caporaso et al., 2010)
qiime feature-classifier extract-reads \
  --i-sequences output/qiime2_16S/classifier_training/silva-138-99-seqs.qza \
  --p-f-primer ACTCCTACGGGAGGCAGCAG \
  --p-r-primer GGACTACHVGGGTWTCTAAT \
  --p-min-length 100 \
  --p-max-length 600 \
  --o-reads output/qiime2_16S/classifier_training/ref-seqs.qza
qiime tools export --output-path output/qiime2_16S/classifier_training --input-path output/qiime2_16S/classifier_training/ref-seqs.qza
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads output/qiime2_16S/classifier_training/ref-seqs.qza \
  --i-reference-taxonomy output/qiime2_16S/classifier_training/silva-138-99-tax.qza \
  --o-classifier output/qiime2_16S/classifier_training/silva_138_99_classifier.qza
qiime feature-classifier classify-sklearn \
  --i-classifier output/qiime2_16S/classifier_training/silva_138_99_classifier.qza \
  --i-reads output/qiime2_16S/rep-seqs-dada2.qza \
  --o-classification output/qiime2_16S/taxonomy.qza  

qiime feature-classifier classify-sklearn \
  --i-classifier output/qiime2_16S/classifier_training/silva_138_99_classifier.qza \
  --i-reads output/qiime2_16S/rep-seqs-dada2.qza \
  --o-classification output/qiime2_16S/taxonomy.qza
qiime metadata tabulate \
  --m-input-file output/qiime2_16S/taxonomy.qza \
  --o-visualization output/qiime2_16S/taxonomy.qzv
qiime tools export --output-path output/qiime2_16S/taxonomy-export.txt --input-path output/qiime2_16S/taxonomy.qza
qiime taxa filter-table \
  --i-table output/qiime2_16S/table-dada2.qza \
  --i-taxonomy output/qiime2_16S/taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table output/qiime2_16S/table-no-mitochondria-no-chloroplast.qza
qiime diversity alpha-rarefaction \
  --i-table table-no-mitochondria-no-chloroplast.qza \
  --p-max-depth 2000 \
  --p-steps 10 \
  --o-visualization alpha-rarefaction_zoom_2.qzv
qiime feature-table summarize \
  --i-table output/qiime2_16S/table-no-mitochondria-no-chloroplast.qza \
  --o-visualization output/qiime2_16S/table-no-mitochondria-no-chloroplast.qzv \
  --m-sample-metadata-file metadata.tsv
qiime feature-table filter-samples \
  --i-table table-no-mitochondria-no-chloroplast.qza \
  --m-metadata-file metadata.tsv \
  --p-min-frequency 1000 \
  --o-filtered-table output/qiime2_16S/table_wo_low_counts.qza
qiime feature-table summarize \
  --i-table table_wo_low_counts.qza \
  --o-visualization output/qiime2_16S/table_wo_low_counts.qzv \
  --m-sample-metadata-file metadata.tsv
