#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);

my ($input, $output, $config); 

GetOptions (
    'input|i=s' => \$input,
    'output|o=s' => \$output,
    'config|c=s' => \$config,
);

my %info;
read_config ($config, \%info);
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $report_path = $info{report_path};
my $project_id = $info{project_id};
my $in_0_1 = $report_path;

my ($in_1, $in_2, $in_3, $in_4, $in_5, $in_6, $in_7, $in_8) = split /\,/, $input;


foreach my $id (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;

    ##01_variant_report
    my $ftp_in_0_1 = "$in_0_1/Analysis_report_$project_id\.pdf";
    my $ftp_out_0_1 = "$output/00_report/01_variant_report";
    cp_file ($ftp_in_0_1, $ftp_out_0_1);

    ##02_sv_report
    my $ftp_in_0_2 = "$in_8/multisample/*";
    my $ftp_out_0_2 = "$output/00_report/02_sv_report";
    cp_file ($ftp_in_0_2, $ftp_out_0_2); 

    ##01_fastq_file
    my $ftp_in_1 = "$in_1/$tbi_id/";
    my $ftp_out_1 = "$output/01_fastq_file/$delivery_id/";
    SoftLink ($ftp_in_1, $ftp_out_1);

    ##02_bam_file
    my $ftp_in_2 = "$in_2/$tbi_id/Projects/default/default/sorted.bam";
    my $ftp_out_2 = "$output/02_bam_file/$delivery_id/$delivery_id\.bam";
    SoftLink ( $ftp_in_2, $ftp_out_2);
    
    my $ftp_in_2_1 = "$in_2/$tbi_id/Projects/default/default/sorted.bam.bai";
    my $ftp_out_2_1 = "$output/02_bam_file/$delivery_id/$delivery_id\.bam.bai";
    SoftLink ( $ftp_in_2_1, $ftp_out_2_1);
    
    my $ftp_in_2_2 = "$in_2/$tbi_id/Projects/default/default/sorted.bam.md5";
    my $ftp_out_2_2 = "$output/02_bam_file/$delivery_id/$delivery_id\.md5";
    SoftLink ( $ftp_in_2_2, $ftp_out_2_2);

    ##03_vcf_file
    my $ftp_in_3 = "$in_3/$tbi_id/$tbi_id\.sorted.genome.PASS.vcf";
    my $ftp_out_3 = "$output/03_vcf_file/$delivery_id/$delivery_id\.PASS.vcf";
    SoftLink ( $ftp_in_3, $ftp_out_3);

    ##04_annotation_file
    my $ftp_in_4 = "$in_4/$tbi_id/$tbi_id\.snpeff.isoform.tsv";
    my $ftp_out_4 = "$output/04_annotation_file/$delivery_id/$delivery_id\.snpeff.isoform.tsv";
    SoftLink ( $ftp_in_4, $ftp_out_4);

    ##05_cnv_file
    my $ftp_in_5 = "$in_5/$tbi_id/$delivery_id\.gene.gainloss.txt";
    my $ftp_out_5 = "$output/05_cnv_file/$delivery_id/$delivery_id\.gene.gainloss.txt";
    SoftLink ( $ftp_in_5, $ftp_out_5);

    ##06_sv_file
    my $ftp_in_6 = "$in_6/$tbi_id/$delivery_id\*PASS.vcf";
    my $ftp_out_6 = "$output/06_sv_file/$delivery_id/.";
    SoftLink ( $ftp_in_6, $ftp_out_6);

}


sub cp_file {
    my ($in_file, $out_file) = @_;
#    checkFile($in_file);
    make_dir($out_file);
    my $cp_cmd = "cp -r $in_file $out_file";
    system ($cp_cmd);
}

sub SoftLink{
    my ($in_file, $out_file) = @_;
#    checkFile($in_file);
    my $output_dir = dirname ($out_file);
    make_dir($output_dir);
    my $link_cmd = "ln -s $in_file $out_file";
    system ($link_cmd);
}
