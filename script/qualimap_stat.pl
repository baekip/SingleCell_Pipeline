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
my $sh_file = sprintf ('%s/%s', $sh_path, "qualimap_stat.$sample.sh");

my $dir_script = dirname (abs_path $0);
my $run_script = "$dir_script/statistics.pl";

open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash \n";
print $fh_sh "#\$ -N qualimap_stat.$sample.1 \n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads \n";
#print $fh_sh_1 "#\$ -q $queue \n";
print $fh_sh "date\n";
print $fh_sh "perl $run_script -p $program -i $input_path -S $sample -l $sh_path -o $output_path -t $threads -c $config_file\n";
print $fh_sh "date";
close $fh_sh;
cmd_system ($sh_path, $hostname, $sh_file);

