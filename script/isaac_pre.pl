#!/usr/bin/perl 

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/../library';
use Utils qw(make_dir checkFile cmd_system);


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
my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

if ( -d $output_path ) {
    my $cmd = "rm -r $output_path";
    system($cmd);
}

my $sh_file = sprintf ("%s/%s", $sh_path, "isaac_pre.$sample.sh");
make_dir($sh_path);
open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N isaac_pre.$sample\n";
print $fh_sh "#\$ -wd $sh_path\n";
print $fh_sh "#\$ -pe smp $threads\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";

my @fastq_R1_list = glob ("$input_path/*_R1*.{fastq,fq}.gz");
my @fastq_R2_list = glob ("$input_path/*_R2*.{fastq,fq}.gz");


if (scalar (@fastq_R1_list) == 0 || scalar (@fastq_R2_list) == 0){
    die "ERROR: Not exist!! check your rawdata file <$input_path>";
}elsif (scalar (@fastq_R1_list) != scalar (@fastq_R2_list) ){
    die "ERROR: Not inconsistent!! check your rawdata file R1, R2 <$input_path>";
}else{
    make_dir($output_path);
    for (my $i=0; $i<@fastq_R1_list; $i++) {
        my $j=$i+1;
        my $isaac_pattern_1 = "$output_path/lane$j\_read1.fastq.gz";
        printf $fh_sh ("ln -s %s %s \n", $fastq_R1_list[$i], $isaac_pattern_1);
    }
    for (my $i=0; $i<@fastq_R2_list; $i++) {
        my $j=$i+1;
        my $isaac_pattern_2 = "$output_path/lane$j\_read2.fastq.gz";
        printf $fh_sh ("ln -s %s %s \n", $fastq_R2_list[$i], $isaac_pattern_2);
    }
}

print $fh_sh "date\n";
close $fh_sh;

cmd_system ($sh_path, $hostname, $sh_file);

#system ("bash $sh_file");


#ln_file_1 ($input_path, \@fastq_R1_list, $output_path, $sh_file);
#ln_file_2 ($input_path, \@fastq_R2_list, $output_path, $sh_file);
#
#sub ln_file_1 {
#    my ($input, $list, $output, $sh) = @_;
#        for (my $i=1; $i<@$list; $i++){
#            my $isaac  = "lane$i\_read1.fastq.gz";
#            printf  
#    }
#}
#
#sub ln_file_2 {
#    my ($input, $list, $output, $sh) = @_;
#        for (my $i=1; $i<@$list; $i++){
#            my $isaac = "lane$i\_read2.fastq.gz";
#    }
#}
#            
