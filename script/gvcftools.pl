#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd qw(abs_path);
use Sys::Hostname; 
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);


my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $option, $config_file)=@_;

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
#print $input_path."\n";

my %info;
read_config ($config_file, \%info);

my $reference = $info{reference};
my $ivc_config = $info{ivc_config};
$input_path = "$input_path/$sample";
#checkFile ("$input_path/results/sorted.genome.vcf.gz");
#checkFile ("$input_path/results/sorted.genome.vcf.gz.tbi");

my $sh_file = sprintf ('%s/%s', $sh_path, "starling.$sample.sh");

open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N starling_pre.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";

printf $fh_sh ("ln -s %s %s \n", "$input_path/results/$sample.genome.vcf.gz", "$output_path/$sample.vcf.gz");
printf $fh_sh ("ln -s %s %s \n", "$input_path/results/$sample.genome.vcf.gz.tbi", "$output_path/$sample.vcf.gz.tbi"); 
printf $fh_sh ("gzip -dc %s | %s | awk \'/^#/ || \$7 == \"PASS\" \'> %s\n " ,"$input_path/results/$sample.genome.vcf.gz", $program, "$output_path/$sample.sorted.genome.PASS.vcf");

print $fh_sh "date\n";
close $fh_sh;
cmd_system ($sh_path, $hostname, $sh_file);
#my $stdout =  system (sprintf ("qsub -V -e %s -o %s -S /bin/bash %s", $sh_path, $sh_path, $sh_file));
