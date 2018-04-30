#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system trim);

my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $option, $config_file);
GetOptions (
    'script|S=s' => \$script,
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample_id|S=s' => \$sample,
    'log_path|l=s' => \$sh_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$threads,
    'option|r=s' => \$option,
    'config|c=s' => \$config_file
);


#my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

make_dir ($sh_path);
make_dir ($output_path);

#######read qualimap result#######
my $qualimap_txt = "$input_path/genome_results.txt";
checkFile($qualimap_txt);
my $parse_stat = "$output_path/$sample.qualimap.stat.txt";
open my $fh_parse, '>', $parse_stat or die;

my %txt_contents;
read_txt ($qualimap_txt, \%txt_contents);

my $reference_bases = $txt_contents{"number of bases"};
$reference_bases =~ s/\s+bp//g;
my ($mapped_read, $mapped_percent) = split /\s/, $txt_contents{"number of mapped reads"};
my $mapped_bases = $txt_contents{"number of mapped bases"};
$mapped_bases =~ s/\s+bp//g;
my $mean_insert_size = $txt_contents{"mean insert size"};
$mean_insert_size =~ s/,//g;
$mean_insert_size = RoundXL($mean_insert_size,2);
my $std_insert_size = $txt_contents{"std insert size"};
$std_insert_size =~ s/,//g;
$std_insert_size = RoundXL($std_insert_size, 2);
my $median_insert_size = $txt_contents{"median insert size"};
my $mean_coverage = $txt_contents{"mean coverageData"};
$mean_coverage =~ s/X//g;
$mean_coverage = RoundXL($mean_coverage, 2);
my $std_coverage = $txt_contents{"std coverageData"};
$std_coverage =~ s/X//g;
$std_coverage = RoundXL($std_coverage, 2);
my $gc_percent = $txt_contents{"GC percentage"};

print $fh_parse "Sample ID\tReference(bp)\tMapped reads\tMapped bases\tMedian insert size\tMean Coverage\tstd coverage\tGC(%)\n";
print $fh_parse "$sample\t$reference_bases\t$mapped_read\t$mapped_bases\t$median_insert_size\t$mean_coverage\t$std_coverage\t$gc_percent\n";

#print $fh_parse "Sample ID\tReference(bp)\tMapped reads\tMapped bases\tMean insert size\tstd insert size\tMean Coverage\tstd coverage\tGC(%)\n";
#print $fh_parse "$sample\t$reference_bases\t$mapped_read\t$mapped_bases\t$mean_insert_size\t$std_insert_size\t$mean_coverage\t$std_coverage\t$gc_percent\n";
close $fh_parse;


#############################################################
sub read_txt {
    my ($txt, $hash_ref) = @_;
    open my $fh_txt, '<:encoding(UTF-8)', $txt or die;
    while (my $row = <$fh_txt>){
        chomp $row;
        if ($row =~ /^>+|^-+/) {next;}
        if (length($row) == 0) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim ($value);
        $hash_ref->{$key}=$value;
    }close $fh_txt;
}

sub RoundXL {
    sprintf ("%.$_[1]f", $_[0]);
}
