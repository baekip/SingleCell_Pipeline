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
my $sh_file_1 = sprintf ('%s/%s', $sh_path, "fastqc.$sample.1.sh");
my $sh_file_2 = sprintf ('%s/%s', $sh_path, "fastqc.$sample.2.sh");
$input_path = "$input_path/$sample";

open my $fh_sh_1, '>', $sh_file_1 or die;
print $fh_sh_1 "#!/bin/bash \n";
print $fh_sh_1 "#\$ -N fastqc.$sample.1 \n";
print $fh_sh_1 "#\$ -wd $sh_path \n";
print $fh_sh_1 "#\$ -pe smp $threads \n";
#print $fh_sh_1 "#\$ -q $queue \n";
print $fh_sh_1 "date\n";

open my $fh_sh_2, '>', $sh_file_2 or die;
print $fh_sh_2 "#!/bin/bash\n";
print $fh_sh_2 "#\$ -N fastqc.$sample.2 \n";
print $fh_sh_2 "#\$ -wd $sh_path \n";
print $fh_sh_2 "#\$ -pe smp $threads \n";
#print $fh_sh_2 "#\$ -q $queue \n";
print $fh_sh_2 "date\n";

my @fastq_R1_list = glob ("$input_path/*_R1*.{fastq,fq}.gz");
my @fastq_R2_list = glob ("$input_path/*_R2*.{fastq,fq}.gz");

my $fastq_1 = sprintf ('%s/%s', $output_path, "$sample\_R1.fastq.gz");
my $fastq_2 = sprintf ('%s/%s', $output_path, "$sample\_R2.fastq.gz");

my $md5_1 = sprintf ('%s/%s', $output_path, "$sample\_R1.md5.txt");
my $md5_2 = sprintf ('%s/%s', $output_path, "$sample\_R2.md5.txt");

if (scalar (@fastq_R1_list) == 0 || scalar (@fastq_R2_list) == 0){
    die "ERROR: Not exist!! check your rawdata file <$input_path>";
}elsif (scalar (@fastq_R1_list) != scalar (@fastq_R2_list) ){
    die "ERROR: Not inconsistent!! check your rawdata file R1, R2 <$input_path>";
}elsif ( scalar (@fastq_R1_list) == 1 ){
    printf $fh_sh_1 ("ln -s %s %s \n", $fastq_R1_list[0], $fastq_1);
    printf $fh_sh_1 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_1);
    printf $fh_sh_1 ("md5sum %s > %s\n", $fastq_1, $md5_1);

    printf $fh_sh_2 ("ln -s %s %s \n", $fastq_R2_list[0], $fastq_2);
    printf $fh_sh_2 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_2);
    printf $fh_sh_2 ("md5sum %s > %s\n", $fastq_2, $md5_2);
}else{
    my $fastq_list_1 = join ' ', @fastq_R1_list;
    printf $fh_sh_1 ("cat %s > %s\n", $fastq_list_1, $fastq_1);
    printf $fh_sh_1 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_1);
    printf $fh_sh_1 ("md5sum %s > %s\n", $fastq_1, $md5_1);

    my $fastq_list_2 = join ' ', @fastq_R2_list;
    printf $fh_sh_2 ("cat %s > %s\n", $fastq_list_2, $fastq_2); 
    printf $fh_sh_2 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_2);
    printf $fh_sh_2 ("md5sum %s > %s\n", $fastq_2, $md5_2);

}

print $fh_sh_1 "date\n";
print $fh_sh_2 "date\n";

close $fh_sh_1;
close $fh_sh_2;

cmd_system ($sh_path, $hostname, $sh_file_1);
cmd_system ($sh_path, $hostname, $sh_file_2);

#sub run_program {
#    my ($input_path, $sample, $log_path) = @_;
##    my ($program, $input_path, $sample, $log_path, $output_path, $threads) = @_;
##   printf ("The size are %d, %d, and $d\n", $size1, $size2, $size3) 
#    my @fastq_R1_list = glob("$input_path/$sample/*_R1.{fastq,fq}.gz");
#    my @fastq_R2_list = glob("$input_path/$sample/*_R2.{fastq,fq}.gz");
#    
#    #*_R1.fastq.gz
#    my $sh_file_1 = "$log_path/$sample/fastq.$sample.1.sh";
#    open my $fh_1,'>', $sh_file_1 or die;
#
#    if (!defined @fastq_R1_list){
#       die "ERROR: Check your lawdata file <$input_path/$sample>!!";
#   }elsif (@fastq_R1_list = 1 ){
#        printf $fh_1 "#!/bin/bash\n";
#        printf $fh_1 "date\n";
#        printf $fh_1 ("ln -s %s, %s", $fastq_R1_list[1], "$input_path/$sample/$sample\_R1.fastq.gz");
#        printf $fh_1 ("%s, -t %d, -o %s, %s\n", $program, $threads, $result_path, $rawdata_1);
#        printf $fh_1 "date\n";
#        close $fh_1;
#   }else {
#       foreach my $id (@fastq_R1_list){
#           printf $fh_1 "#!/bin/bash\n";
#           printf $fh_1 "date\n";
#           printf $fh_1 ("%s, -t %d, -o %s, %s\n", $program, $threads, $result_path, $rawdata_1);
#           printf $fh_1 "date\n";
#           close $fh_1;
#       }
#   }
#
#   #*_R2.fastq.gz
#   my $sh_file_2 = "$log_path/$sample/fastq.$sample.2.sh";
#   open my $fh_2, '>', $sh_file_2 or die;
#   if (!defined @fastq_R1_list){
#       die "ERROR: Check your lawdata file <$input_path/$sample>!!";
#   }elsif (@fastq_R2_list){
#       printf $fh_2 "#!/bin/bash\n";
#       printf $fh_2 "date\n";
#       printf $fh_2 ("ln -s %s, %s", $fastq_R2_list[1], "$input_path/$sample/$sample\_R2.fastq.gz");
#       printf $fh_2 ("%s, -t %d, -o %s, %s\n", $program, $threads, $result_path, $rawdata_2);
#       printf $fh_2 "date\n";
#       close $fh_2;
#   }else {
#        my $list = join " ", @fastq_R2_list)    
#        printf $fh_2 "#!/bin/bash\n";
#        printf $fh_2 "date\n";
#        printf $fh_2 ("cat %s > %s", $list, $rawdata_1);
#        printf $fh_2 ("%s, -t %d, -o %s, %s\n", $program, $threads, $result_path, $rawdata_2);
#        printf $fh_2 "date\n";
#        close $fh_2;
#       }
#   }
#}
#

