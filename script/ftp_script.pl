#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename; 
use lib dirname (abs_path $0) . '/../library';
use Utils qw(checkDir make_dir checkFile read_config cmd_system);

my ($input, $output, $config); 

GetOptions (
    'input|i=s' => \$input,
    'output|o=s' => \$output,
    'config|c=s' => \$config,
);

if ( -d $output ) {
    `rm -r $output`;
}

my %info;
read_config ($config, \%info);
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $rawdata_path = $info{rawdata_path};
my $report_path = $info{report_path};
my $project_id = $info{project_id};
my $dir_script = dirname (abs_path $0);

my $link_report_path = "$output/00_report";
my $link_fastq_path = "$output/01_fastq_file";
my $link_bam_path = "$output/02_bam_file";

make_dir ($link_report_path);
make_dir ($link_fastq_path);
make_dir ($link_bam_path);

my ($input_fastq, $input_cellranger) = split /\,/, $input;
my @input_list = split /\,/, $input;

#copy report
my $report_file = "$report_path/scRNA_report";
checkDir ($report_file);
system ("ln -s $report_file $link_report_path");

#softlink
foreach my $id (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    foreach my $tmp_input (@input_list) {
        if ( $tmp_input =~ /cutadapt/ ) {
            my @result_list = glob ("$tmp_input/$tbi_id/*fastq.gz");
            change_name($tbi_id, $delivery_id, $tmp_input, $link_fastq_path, @result_list);
        }elsif ( $tmp_input =~ /cellranger_count/) {
            my @result_list = glob ("$tmp_input/$tbi_id/$tbi_id/outs/*bam*");
            change_name($tbi_id, $delivery_id, $tmp_input, $link_bam_path, @result_list);
        }
    }
}

##sub routine
sub change_name {
    my ($tbi_id, $delivery_id, $tmp_input, $tmp_output, @result_list) = @_;
    foreach my $list (@result_list){
        my $result_filename = basename($list);
        my $output_path = "$tmp_output/$delivery_id";
        my $link_result = $result_filename;
        $link_result =~ s/$tbi_id/$delivery_id/g;
        my $link_result_path = "$tmp_output/$delivery_id";
        make_dir ($link_result_path);
        $link_result = "$link_result_path/$link_result";
        my $link_cmd = "ln -s $list $link_result\n";
        system($link_cmd);
    }
}

sub copy_file {
    my ($input_file, $output_file) = @_;
    if ( -f $input_file | -d $input_file ) {
        my $cp_cmd = "cp -r $input_file $output_file";
        system($cp_cmd)
    }else{
        die "Error! Check Your Report File <$input_file>\n";
    }
}
