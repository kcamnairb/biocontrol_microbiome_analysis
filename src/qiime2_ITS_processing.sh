#!/bin/bash
set -x
set -e
set -u

source activate qiime2-2021.4
qiime tools import \
  --type SampleData[SequencesWithQuality] \
  --input-format SingleEndFastqManifestPhred33 \
  --input-path data/manifest.csv \
  --output-path output/qiime2_ITS/sequences.qza
qiime demux summarize \
  --i-data output/qiime2_ITS/sequences.qza \
  --o-visualization output/qiime2_ITS/sequences.qzv

qiime cutadapt trim-single \
  --i-demultiplexed-sequences output/qiime2_ITS/sequences.qza \
  --p-adapter GCATCGATGAAGAACGCAGC \
  --o-trimmed-sequences output/qiime2_ITS/adapter_read_through_trimmed.qza \
  --verbose \
  --p-cores 28
qiime demux summarize \
  --i-data output/qiime2_ITS/adapter_read_through_trimmed.qza \
  --o-visualization output/qiime2_ITS/adapter_read_through_trimmed.qzv
mkdir -p output/qiime2_ITS/adapter_read_through_trimmed_fastq
qiime tools extract \
  --input-path output/qiime2_ITS/adapter_read_through_trimmed.qza \
  --output-path output/qiime2_ITS/adapter_read_through_trimmed_fastq
mv output/qiime2_ITS/adapter_read_through_trimmed_fastq/*/data/*fastq.gz output/qiime2_ITS/adapter_read_through_trimmed_fastq
mkdir -p output/qiime2_ITS/standalone/{fastq,tmp}
fastqs=$(ls output/qiime2_ITS/adapter_read_through_trimmed_fastq/*R1*.fastq.gz)
for fastq in $fastqs ; do
base=$(basename $fastq)
itsxpress --fastq $fastq \
  --single_end --keeptemp --region ITS1 \
  --outfile output/qiime2_ITS/standalone/fastq/$base \
  --taxa Fungi --log output/qiime2_ITS/standalone/${base}_log.txt --threads 30 --tempdir output/qiime2_ITS/standalone/tmp
done

qiime tools import \
  --type SampleData[SequencesWithQuality] \
  --input-format SingleEndFastqManifestPhred33 \
  --input-path data/manifest_trimmed.csv \
  --output-path output/qiime2_ITS/trimmed.qza
qiime demux summarize \
  --i-data output/qiime2_ITS/trimmed.qza \
  --o-visualization output/qiime2_ITS/trimmed.qzv
qiime demux summarize \
  --i-data output/qiime2_ITS/trimmed.qza \
  --o-visualization output/qiime2_ITS/trimmed.qzv
qiime dada2 denoise-single \
  --i-demultiplexed-seqs output/qiime2_ITS/trimmed.qza \
  --p-trunc-len 160 \
  --p-n-threads 30 \
  --output-dir output/qiime2_ITS/dada2out_160 
wget -p output/qiime2_ITS/ https://files.plutof.ut.ee/doi/0A/0B/0A0B25526F599E87A1E8D7C612D23AF7205F0239978CBD9C491767A0C1D237CC.zip
unzip output/qiime2_ITS/0A0B25526F599E87A1E8D7C612D23AF7205F0239978CBD9C491767A0C1D237CC.zip
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path output/qiime2_ITS/sh_refs_qiime_ver7_dynamic_01.12.2017.fasta \
  --output-path output/qiime2_ITS/unite.qza
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path output/qiime2_ITS/sh_taxonomy_qiime_ver7_dynamic_01.12.2017.txt \
  --output-path output/qiime2_ITS/unite-taxonomy.qza  
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads output/qiime2_ITS/unite.qza \
  --i-reference-taxonomy output/qiime2_ITS/unite-taxonomy.qza \
  --o-classifier output/qiime2_ITS/classifier.qza 
qiime feature-classifier classify-sklearn \
  --i-classifier output/qiime2_ITS/classifier.qza \
  --i-reads output/qiime2_ITS/dada2out_160/representative_sequences.qza \
  --o-classification output/qiime2_ITS/taxonomy.qza  
qiime metadata tabulate \
  --m-input-file output/qiime2_ITS/taxonomy.qza \
  --o-visualization output/qiime2_ITS/taxonomy.qzv  
qiime taxa barplot \
  --i-table output/qiime2_ITS/dada2out_160/table.qza  \
  --i-taxonomy output/qiime2_ITS/taxonomy.qza \
  --m-metadata-file data/metadata.tsv \
  --o-visualization output/qiime2_ITS/taxa-bar-plots.qzv  
qiime feature-table summarize \
  --i-table output/qiime2_ITS/dada2out_160/table.qza \
  --o-visualization output/qiime2_ITS/dada2out_160/table.qzv \
  --m-sample-metadata-file data/metadata.tsv
