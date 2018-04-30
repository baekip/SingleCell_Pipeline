#!/usr/bin/perl

use strict;
use warnings;

#output: TN1803L0441_S8_L008_R1_001.fastq.gz
my $sample = "TN1803L0441";
my $example = "TN1803L0441--TGCTGAGT-1_S8_L008_R1_001.fastq.gz";

my @list = split /--([TCGA]*)/, $example;
foreach (@list){
    print $_."\n";
}
#print $example."\n";
#print $output."\n";

