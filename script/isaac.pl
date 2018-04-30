#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);


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


my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

make_dir ($sh_path);
make_dir ($output_path);

my ($input_path_1, $input_path_2) = split /\,/, $input_path;
my ($threads_1, $threads_2) = split /\,/, $threads;

my %info;
my $sh_file_1 = sprintf ('%s/%s', $sh_path, "isaac.$sample.1.sh");
read_config ($config_file, \%info);
my $sorted_reference = $info{sorted_reference};
my $read_length = $info{read_length};
my $memory = $info{isaac_memory};

open my $fh_sh_1, '>', $sh_file_1 or die;
print $fh_sh_1 "#!/bin/bash\n";
print $fh_sh_1 "#\$ -N isaac.$sample.1\n";
print $fh_sh_1 "#\$ -wd $sh_path \n";
print $fh_sh_1 "#\$ -pe smp $threads_1\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh_1 "date\n";

printf $fh_sh_1 ("%s -r %s -b %s -o %s -t %s --default-adapters Standard -f fastq-gz --use-bases-mask y%s,y%s -m %d -j %d\n", $program, $sorted_reference, "$input_path_1/$sample", $output_path, "$output_path/Temp/", $read_length, $read_length, $memory, $threads_1);

print $fh_sh_1 "date\n";
close $fh_sh_1;


#----------------
my $dir_script = dirname (abs_path $0);
my $run_script = "$dir_script/../util/FasterFastqStatistics";
my $sh_file_2 = sprintf ('%s/%s', $sh_path, "isaac.$sample.2.sh");
open my $fh_sh_2, '>', $sh_file_2 or die;
print $fh_sh_2 "#!/bin/bash\n";
print $fh_sh_2 "#\$ -N isaac.$sample.2\n";
print $fh_sh_2 "#\$ -wd $sh_path \n";
print $fh_sh_2 "#\$ -pe smp $threads_2\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh_2 "date\n";

printf $fh_sh_2 ("%s %s %s\n", $run_script, "$input_path_2/$sample/$sample\_R1.fastq.gz", "$input_path_2/$sample/$sample\_R2.fastq.gz");

print $fh_sh_2 "date\n";
print $fh_sh_2;
close $fh_sh_2;

cmd_system ($sh_path, $hostname, $sh_file_2);
cmd_system ($sh_path, $hostname, $sh_file_1);
