# Data and analysis for Moore et al. (2023)

<!-- badges: start -->
[![DOI](https://img.shields.io/badge/DOI-10.15482/USDA.ADC/1529555-<COLOR>.svg)](https://doi.org/10.15482/USDA.ADC/1529555)
<!-- badges: end -->

This repository contains the code and data to reproduce the figures and analyses in the manuscript

Moore, Geromy G., Subbaiah Chalivendra, Brian Mack, Matthew K. Gilbert, Jeffrey William Cary, and Kanniah Rajasekaran. "Microbiota of maize kernels as influenced by Aspergillus flavus infection in susceptible and resistant inbreds." Frontiers in Microbiology 14: 1291284. doi.org/10.3389/fmicb.2023.1291284

The paper investigates how biocontrol application affects the diversity and composition of the bacterial and fungal communities associated with maize kernels, using 16S and ITS amplicon sequencing.


## Data

The data folder contains the following files:

- `16S/table_wo_outliers.qza`: A QIIME2 artifact with the 16S ASV abundances for each sample.
- `16S/taxonomy.qza`: A QIIME2 artifact the taxonomic assignment for each 16S ASV.
- `16S/rooted-tree.qza`: A QIIME2 artifact containing the phylogenetic tree for the 16S ASVs.
- `16S/metadata.csv`: A table with the sample information.
- `ITS/table_wo_outliers.qza`: A QIIME2 artifact with the ITS ASV abundances for each sample.
- `ITS/taxonomy.qza`: A QIIME2 artifact the taxonomic assignment for each ITS ASV.
- `ITS/rooted-tree.qza`: A QIIME2 artifact containing the phylogenetic tree for the ITS ASVs.
- `ITS/metadata.csv`: A table with the sample information.
  
Raw sequencing reads are available at ENA project [PRJEB66233](https://www.ebi.ac.uk/ena/browser/view/PRJEB66233)

## Code

The src folder contains the following R scripts:

- `01_data_import.Rmd`: Loads and processes the data, and creates phyloseq objects.
- `02_alpha_diversity.Rmd`: Calculates and plots the alpha diversity and compares the alpha diversity between the different conditions.
- `03_beta_diversity.Rmd`: Calculates and plots the beta diversity distances and ordinations and compared beta diversity among sample conditions using PERMANOVA.
- `04_differential_abundance.Rmd`: Performs differential abundance analysis using ANCOM-BC and plots log2 fold change heatmaps and barcharts.
- `05_A_flavus_ASVs.Rmd`: Plots and compares the abundance of the K49 and Tox4 ASVs in the different conditions.
- `06_cross_domain_network_corn_diff_assoc.Rmd`: Creates and compares co-occurrence networks for each Maize inbred, and identifies taxa that are correlated with Tox4 and K49 ASVs.
- `qiime2_16S_processing.sh`: QIIME2 commands to denoise and trim reads and assign taxonomic classification for 16S amplicons.
- `qiime2_ITS_processing.sh` QIIME2 commands to denoise and trim reads and assign taxonomic classification for ITS amplicons.

## Output

The output folder contains tables with ASV counts alongside their amplicon sequence taxonomy. There are also tables showing the differential abundance log2 fold change for both ITS and 16S ASVs.

## Requirements

To run the code, you will need R-4.2.1 and the following R packages:

- tidyverse
- qiime2R
- ggeasy
- phyloseq
- Biostrings
- ggsignif
- ggeasy
- ggpubr
- readxl
- patchwork
- DESeq2
- ALDEx2
- microbiome
- vegan
- ANCOMBC
- glue
- ggstatsplot
- beeswarm
- msa
- here
- ggtext
- kableExtra
- tidyHeatmap
- SpiecEasi
- NetCoMi
- igraph
- tidygraph
- ggraph
