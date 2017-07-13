#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd qw(abs_path);
use Sys::Hostname;
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

$input_path="$input_path/$sample";
my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

make_dir ($sh_path);
make_dir ($output_path);

my $sh_file = sprintf ('%s/%s', $sh_path, "starling_pre.$sample.sh");

open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N starling_pre.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";

#/TBI/Share/HumanTeam/BioProject/Isaac_PhiX_Test/result/03_isaac_orig/Sample01/Projects/Sample01/Sample01

printf $fh_sh ("ln -s %s %s\n", "$input_path/Projects/default/default/sorted.bam", "$output_path/$sample.bam");
printf $fh_sh ("ln -s %s %s\n", "$input_path/Projects/default/default/sorted.bam.bai", "$output_path/$sample.bam.bai");
printf $fh_sh ("ln -s %s %s\n", "$input_path/Projects/default/default/sorted.bam.md5", "$output_path/$sample.bam.md5");

print $fh_sh "date\n";
close $fh_sh;

cmd_system ($sh_path, $hostname, $sh_file);
