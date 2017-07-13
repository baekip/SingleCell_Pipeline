#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Report;
use Exporter qw(import);
our @EXPORT_OK = qw(report_header report_opt report_int report_info report_workflow);
#############################################################
##sub
##############################################################
sub report_header {
    my ($fh, $ver, $project_id) = @_;
    
    print $fh "---
title: \"$project_id - SV Analysis Report $ver\"
author: \"TheragenEtex Bio Institute\"
date: \"\`r Sys.Date\(\)\`\"
output:
  rmdformats::readthedown:
    self_contained: no
    thumbnails: true
    lightbox: true
    gallery: false
---

[Theragene Etex Bio Institute](http://www.thera-gen.com/) is specialized genomics company developing innovative diagnosis tools and new drugs using the genomics and bioinformatics technologies. Theragen Etex Bio Institute\'s world class analysis technologies are proven by number of high impact journal publications.
                        
 Proudly, we are the fifth organization in the world, which completed sequencing and assembly of an entire Human genome. In June 2013, we were recognized as the first group to identify genes that are related to Koran gastric cancer. In January 2014, we have secured the cover of the Nature Genetics with our research on the world\'s first Minke Whale Genome.
 We are providing genome-based customized research service, such as Genome, Transcriptome and Epigenome. In addition, we have personal genome service \"[HelloGene](http://www.theragenetex.com/kr/bio/services/hellogene/)\", which is screening disease susceptibility, physical traits, drug sensitivity and so on.

 Internationally, the first step has been started in the overseas markets with personal genome analysis service contract with UNIMEX, Philippines in 2011. And a joint venture for entry to the personal genome analysis service in Beijing, China named \'Beijing Theragen Etex & Deyi Tech Co.,Ltd.\'\' has been established . Based on it, Asian genetic information and network have been organizing and gaining a foothold to move forward to global markets.
 Based on these technologies and experiences, we are putting endless efforts to revolutionize personalized medicine and to become a global leader in human welfare and healthcare.\n";
}

sub report_opt {
    my ($fh, $work_path) = @_;
    print $fh "\`\`\`\{r opt,cache=FALSE,echo=FALSE,warning=FALSE, message=FALSE\}
library(knitr)
library(rmarkdown)
library(DT)
library(ggplot2)
library(htmltools)
knitr::opts_chunk\$set(tidy=TRUE, highlight=TRUE, dev=\"png\",cache=FALSE, highlight=TRUE, autodep=TRUE, warning=FALSE, error=FALSE,eval=TRUE, fig.width= 9, echo=FALSE, verbose=FALSE, message=FALSE, prompt=TRUE, comment=\'\', fig.cap=\'\',bootstrap.show.code=FALSE)
\`\`\`
\n\n";

    print $fh "\`\`\`\{r setup, include=FALSE\}
project_path=\"$work_path\"
setwd(project_path)
\`\`\`
\n\n\n";
}

sub report_int {
    my $fh = shift;
    print $fh "# Introuduction

 Copy number changes are a useful diagnostic indicator for many diseases, including cancer. The gold standard for genome-wide copy number is array comparative genomic hybridization (array CGH). More recently, methods have been developed to obtain copy number information from whole-genome sequencing data. For clinical use, sequencing of genome partitions, such as the exome or a set of disease-relevant genes, is often preferred to enrich for regions of interest and sequence them at higher coverage to increase the sensitivity for calling variants. \n";
}

sub report_info {
    my ($fh, $ref) = @_;
    print $fh "## Reference Infromation

Feature                                      Specification
---------------------------------------    ------------------------------------------------------------------------------------
genome / exome source content                $ref

";
}

sub report_workflow {
    my ($fh, $workflow_png) = @_;
    print $fh "# Workflow
http://journals.plos.org/ploscompbiol/article?id=10.1371%2Fjournal.pcbi.1004873

 The input to the program is one or more DNA sequencing read alignments in BAM format and the capture bait locations or a pre-built \"reference\" file. All additional data files used in the workflow, such as GC content and the location of sequence repeats, can be extracted from user-supplied genome sequences in FASTA format using scripts included with the CNVkit distribution. The workflow is not restricted to the human genome, and can be run equally well on other genomes.

\`\`\`{r workflow_png, out.width = \"1200px\",out.heigh=\"1000px\"}
workflow_png = '$workflow_png'
include_graphics(workflow_png)
\`\`\`

The target and off-target bin BED files and reference file are constructed once for a given platform and can be used to process many samples sequenced on the same platform, as shown in the workflow on the left. Steps to construct the off-target bins are shown at the top-right, and construction of the reference is shown at the lower-right. \n\n
http://dx.doi.org/10.1371/journal.pcbi.1004873.g001 \n\n\n\n

#Results\n\n";
}
1;
