#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use File::Basename;
use Text::CSV;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/../library';
use Utils qw(read_config trim make_dir checkFile cmd_system);

my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $option, $config);
GetOptions (
    'script|s=s' => \$script,
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample|S=s' => \$sample,
    'log_path|l=s' => \$sh_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$threads,
    'options|r=s' => \$option,
    'config_file|c=s' => \$config,
);

$input_path="$input_path/$sample";
make_dir($output_path);
make_dir($fh_path);

my $hostname=hostname;


#############################################################
#0.preparation
#############################################################

my %info;
read_config ($config, \%info);

my $project_path=$info{project_path};
my $report_path=$info{report_path};
my $delivery_id=$info{delivery_tbi_id};
my @delivery_list=split /\,/, $delivery_id;
my $script_path = $info{dev_path};

my %hash;
foreach my $id (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    $hash{$tbi_id}->{delivery_id}=$delivery_id;
}

#############################################################
#1.read fastq stats xls file 
#############################################################
my $mapping_file = "$input_path/$sample/outs/metrics_summary.csv";
checkFile($mapping_file);

my %combined;
open my $fh_map, '<:encoding(UTF-8)', $mapping_file or die;
my $csv = Text::CSV->new( { binary => 1 } );

my @headers = @{$csv->getline($fh_map)};
while (my $row = $csv->getline($fh_map)){
    for my $header (@headers){
        push (@{$combined{$header}}, shift(@$row));
    }
}

my @value;
foreach my $tmp_header (@headers){
    push @value, join('', @{$combined{$tmp_header}});
}

my $output_file = "$output_path/$sample.mapping.stat.xls";
open my $fh_stat, '>', $output_file or die;

print $fh_stat "TBI_ID\tDelivery_ID\t".join("\t", @headers)."\n";
print $fh_stat "$sample\t$hash{$sample}{delivery_id}\t".join("\t", @value)."\n";

#my $cells = join ('', @{$combined{'Estimated Number of Cells'}});
#my $mean_reads = join ('', @{$combined{'Mean Reads per Cell'}});


close ($fh_stat);
close ($fh_map);
#############################################################
#sub
#############################################################
sub changeGbp{
    my $val = shift;
    $val = $val/1000000000;
    $val = &RoundXL($val,2);
    return $val;
}

sub RoundXL {
    sprintf("%.$_[1]f", $_[0]);
}

sub checkDir{
    my $dir=shift;
    if (!-d $dir){
        die "ERROR! not exist <$dir>\n";
    }
}

