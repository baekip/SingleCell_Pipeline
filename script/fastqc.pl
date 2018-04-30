#!/usr/bin/perl 

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use File::Basename;
#use File::Basename qw(dirname);
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
my $hostname=hostname;

if ( -d $output_path ) {
    my $cmd = "rm -r $output_path";
    system($cmd);
}

my %info;
read_config ($config, \%info);
#my $fastqc = $info{fastqc};
my $script_path = $info{dev_path};
my $faster = "$script_path/util/FasterFastqStatistics";

make_dir ($sh_path);
make_dir ($output_path);

my $sh_file_I1 = sprintf ('%s/%s', $sh_path, "fastqc.$sample.I1.sh");
my $sh_file_R1 = sprintf ('%s/%s', $sh_path, "fastqc.$sample.R1.sh");
my $sh_file_R2 = sprintf ('%s/%s', $sh_path, "fastqc.$sample.R2.sh");


open my $fh_I1, '>', $sh_file_I1 or die;
print $fh_I1 "#!/bin/bash\n";
print $fh_I1 "#\$ -N fastqc.I1.$sample\n";
print $fh_I1 "#\$ -wd $sh_path\n";
print $fh_I1 "#\$ -pe smp $threads\n";
print $fh_I1 "date\n";

open my $fh_R1, '>', $sh_file_R1 or die;
print $fh_R1 "#!/bin/bash\n";
print $fh_R1 "#\$ -N fastqc.R1.$sample\n";
print $fh_R1 "#\$ -wd $sh_path\n";
print $fh_R1 "#\$ -pe smp $threads\n";
print $fh_R1 "date\n";

open my $fh_R2, '>', $sh_file_R2 or die;
print $fh_R2 "#!/bin/bash\n";
print $fh_R2 "#\$ -N fastqc.R2.$sample\n";
print $fh_R2 "#\$ -wd $sh_path\n";
print $fh_R2 "#\$ -pe smp $threads\n";
print $fh_R2 "date\n";

my $fastq_I1 = sprintf ('%s/%s', $output_path, "$sample\_I1.fastq.gz");
my $fastq_R1 = sprintf ('%s/%s', $output_path, "$sample\_R1.fastq.gz");
my $fastq_R2 = sprintf ('%s/%s', $output_path, "$sample\_R2.fastq.gz");

my $md5_I1 = sprintf ('%s/%s', $output_path, "$sample\_I1.md5.txt");
my $md5_R1 = sprintf ('%s/%s', $output_path, "$sample\_R1.md5.txt");
my $md5_R2 = sprintf ('%s/%s', $output_path, "$sample\_R2.md5.txt");


my @fastq_R1_list = glob ("$input_path/*_R1*.{fastq,fq}.gz");
my @fastq_R2_list = glob ("$input_path/*_R2*.{fastq,fq}.gz");
my @fastq_I1_list = glob ("$input_path/*_I1*.{fastq,fq}.gz");

if (scalar (@fastq_R1_list) == 0 || scalar (@fastq_R2_list) == 0 || scalar(@fastq_I1_list) == 0){
    die "ERROR: Not exist!! check your cutadapt stat file <$input_path>";
}elsif (scalar (@fastq_R1_list) != scalar (@fastq_R2_list) || scalar (@fastq_R2_list) != scalar (@fastq_I1_list) ){
    die "ERROR: Not inconsistent!! check your cutadapt stat file I1, R1, R2 <$input_path>";
}elsif (scalar (@fastq_R1_list) == 1 ){
    printf $fh_I1 ("ln -s %s %s \n", $fastq_I1_list[0], $fastq_I1);
    printf $fh_I1 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_I1);
    printf $fh_I1 ("%s %s\n", $faster, $fastq_I1);
    printf $fh_I1 ("md5sum %s > %s\n", $fastq_I1, $md5_I1);
    
    printf $fh_R1 ("ln -s %s %s \n", $fastq_R1_list[0], $fastq_R1);
    printf $fh_R1 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_R1);
    printf $fh_R1 ("%s %s\n", $faster, $fastq_R1);
    printf $fh_R1 ("md5sum %s > %s\n", $fastq_R1, $md5_R1);

    printf $fh_R2 ("ln -s %s %s \n", $fastq_R2_list[0], $fastq_R2);
    printf $fh_R2 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_R2);
    printf $fh_R2 ("%s %s\n", $faster, $fastq_R2);
    printf $fh_R2 ("md5sum %s > %s\n", $fastq_R2, $md5_R2);
}else {
    
    my $fastq_list_I1 = join ' ', @fastq_I1_list;
    printf $fh_I1 ("cat %s > %s\n", $fastq_list_I1, $fastq_I1);
    printf $fh_I1 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_I1);
    printf $fh_I1 ("%s %s\n", $faster, $fastq_I1);
    printf $fh_I1 ("md5sum %s > %s\n", $fastq_I1, $md5_I1);
    
    my $fastq_list_R1 = join ' ', @fastq_R1_list;
    printf $fh_R1 ("cat %s > %s\n", $fastq_list_R1, $fastq_R1); 
    printf $fh_R1 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_R1);
    printf $fh_R1 ("%s %s\n", $faster, $fastq_R1);
    printf $fh_R1 ("md5sum %s > %s\n", $fastq_R1, $md5_R1);

    my $fastq_list_R2 = join ' ', @fastq_R2_list;
    printf $fh_R2 ("cat %s > %s\n", $fastq_list_R2, $fastq_R2); 
    printf $fh_R2 ("%s -t %d -o %s %s\n", $program, $threads, $output_path, $fastq_R2);
    printf $fh_R2 ("%s %s\n", $faster, $fastq_R2);
    printf $fh_R2 ("md5sum %s > %s\n", $fastq_R2, $md5_R2);
} 

print $fh_I1 "date\n";
print $fh_R1 "date\n";
print $fh_R2 "date\n";

close $fh_I1;
close $fh_R1;
close $fh_R2;

cmd_system ($sh_path, $hostname, $sh_file_I1);
cmd_system ($sh_path, $hostname, $sh_file_R1);
cmd_system ($sh_path, $hostname, $sh_file_R2);
