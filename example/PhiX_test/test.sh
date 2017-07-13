#!/bin/bash
#https://github.com/Illumina/Isaac3
isaac_path=/TBI/Tools/Isaac3/iSSAC-build/
project_path=/TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test


#Prepare reference genome
##This step can take long time on bigger genomes. Normally it is done once per reference and the output is reused in further data analyses.
##$ <isaac>/bin/isaac-sort-reference -g <isaac>/share/*/data/examples/PhiX/iGenomes/PhiX/NCBI/1993-04-28/Sequence/Chromosomes/phix.fa -o ./PhiX

#$isaac_path/
#$isaac_path/bin/isaac-sort-reference \
#    -g $project_path/PhiX/iGenomes/PhiX/NCBI/1993-04-28/Sequence/Chromosomes/phix.fa \
#    -o ./PhiX_ref


#Process fastq data
##Analyze a pair of fastq files and produce bam output.
##$ <isaac>/bin/isaac-align -r ./PhiX/sorted-reference.xml -b <isaac>/share/*/data/examples/PhiX/Fastq -f fastq --use-bases-mask y150,y150 -m40
#$isaac_path/bin/isaac-align \
#    -r $project_path/PhiX_ref/sorted-reference.xml \
#    -b $project_path/input/Fastq/ \
#    -o $project_path/output/ \
#    -t $project_path/output/tmp \
#    -f fastq \
#    -n test \
#    --use-bases-mask y150,y150 \
#    --default-adapters Standard \
#    -j 4 \
#    -m 40

#ivc_path=/TBI/Tools/isaac_variant_caller/
##
##/TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test/input/iGenomes
#
#$ivc_path/bin/configureWorkflow.pl \
#    --bam=/TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test/output/Projects/test/test/sorted.bam \
#    --ref=$project_path/input/iGenomes/PhiX/NCBI/1993-04-28/Sequence/Chromosomes/phix.fa \
#    --config=$ivc_path/etc/ivc_config_default_wgs.ini \
#    --output-dir=./variant_call
#/TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test/variant_call/make
gvcftools=/TBI/Tools/gvcftools/bin/extract_variants
vcf_gz=/TBI/Share/HumanTeam/BioPipeline/Isaac_Pipeline_v1/example/PhiX_test/variant_call/results/sorted.genome.vcf.gz
gzip -dc $vcf_gz |\
    $gvcftools  |\
    awk '/^#/ || $7 == "PASS"' >\
    ./variant_call/all_passed_variants.vcf
