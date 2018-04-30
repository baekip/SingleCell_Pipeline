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

my %info;
read_config ($config, \%info);
my $cutadapt = $info{cutadapt};
my $script_path = $info{dev_path};
my $faster = "$script_path/util/FasterFastqStatistics";

if ( -d $output_path ) {
    my $cmd = "rm -r $output_path";
    system($cmd);
}

my ($option_orig, $R1_length, $R2_length) = split /\,/, $option;
make_dir ($sh_path);
make_dir ($output_path);

#TN1803L0441--TGCTGAGT-1_S8_L008_R1_001.fastq.gz > TN1803L0441_S8_L008_R1_001.fastq.gz
#

my @fastq_I1_list = glob ("$input_path/*_I1*.{fastq,fq}.gz");
my @fastq_R1_list = glob ("$input_path/*_R1*.{fastq,fq}.gz");
my @fastq_R2_list = glob ("$input_path/*_R2*.{fastq,fq}.gz");

if (scalar (@fastq_R1_list) == 0 || scalar (@fastq_R2_list) == 0 || scalar(@fastq_I1_list) == 0){
    die "ERROR: Not exist!! check your cutadapt stat file <$input_path>";
}elsif (scalar (@fastq_R1_list) != scalar (@fastq_R2_list) || scalar (@fastq_R2_list) != scalar (@fastq_I1_list) ){
    die "ERROR: Not inconsistent!! check your cutadapt stat file I1, R1, R2 <$input_path>";
}else {
    
    foreach my $id (@fastq_I1_list){
        my $pattern_I1 = basename($id);
        my ($tmp_sample, $tmp_index, $tmp_tail) = split /-+([TCGA]*)|\-\d/, $pattern_I1;
        if ($tmp_sample ne $sample) {
            exit "check your value of <sample id> and rawdata file";
        }
        $pattern_I1 = "$tmp_sample$tmp_tail";
        my $sh_file_I1 = sprintf ('%s/%s', $sh_path, "cutadapt.I1.$pattern_I1.sh");
        open my $fh_I1, '>', $sh_file_I1 or die;
        print $fh_I1 "#!/bin/bash\n";
        print $fh_I1 "#\$ -N cutadapt.I1.$pattern_I1\n";
        print $fh_I1 "#\$ -wd $sh_path\n";
        print $fh_I1 "#\$ -pe smp $threads\n";
        print $fh_I1 "date\n\n";

        print $fh_I1 "ln -s $id $output_path/$pattern_I1\n";
#        print $fh_I1 "$faster $output_path/$pattern_I1\n\n";

        print $fh_I1 "date\n";
        close $fh_I1;
        cmd_system ($sh_path, $hostname, $sh_file_I1);
    }

    
    foreach my $id (@fastq_R1_list){
        my $orig_length = `zcat $id | head -n 4 | tail -n 1 | wc -c`;
        $orig_length = trim ($orig_length);
        my $trim_length = $orig_length - $R1_length;
        my $pattern_R1 = basename($id);
        my ($tmp_sample, $tmp_index, $tmp_tail) = split /-+([TCGA]*)|\-\d/, $pattern_R1;
        if ($tmp_sample ne $sample) {
            exit "check your value of <sample id> and rawdata file";
        }
        $pattern_R1 = "$tmp_sample$tmp_tail";
        my $sh_file_R1 = sprintf ('%s/%s', $sh_path, "cutadapt.R1.$pattern_R1.sh");
        
        open my $fh_R1, '>', $sh_file_R1 or die;
        print $fh_R1 "#!/bin/bash\n";
        print $fh_R1 "#\$ -N cutadapt.R1.$pattern_R1\n";
        print $fh_R1 "#\$ -wd $sh_path\n";
        print $fh_R1 "#\$ -pe smp $threads\n";
        print $fh_R1 "date\n\n";
        
        if ($trim_length < 0) {
            exit print "ERROR!! Check your R1 trimming length!!!";
        }elsif ($trim_length == 0){
            print $fh_R1 "ln -s $id $output_path/$pattern_R1\n";
#            print $fh_R1 "$faster $output_path/$pattern_R1\n";
        }else {
            print $fh_R1 "$program -u -$trim_length -o $output_path/$pattern_R1 $id \n";
#            print $fh_R1 "$faster $output_path/$pattern_R1\n";
        }
    print $fh_R1 "date\n";
    close $fh_R1;
    cmd_system ($sh_path, $hostname, $sh_file_R1);
    }

    foreach my $id (@fastq_R2_list){
        my $orig_length = `zcat $id | head -n 4 | tail -n 1 | wc -c`;
        $orig_length = trim ($orig_length);
        my $trim_length = $orig_length - $R2_length;
        my $pattern_R2 = basename($id);
        my ($tmp_sample, $tmp_index, $tmp_tail) = split /-+([TCGA]*)|\-\d/, $pattern_R2;
        if ($tmp_sample ne $sample) {
            exit "check your value of <sample id> and rawdata file";
        }
        $pattern_R2 = "$tmp_sample$tmp_tail";
        my $sh_file_R2 = sprintf ('%s/%s', $sh_path, "cutadapt.R2.$pattern_R2.sh");

        open my $fh_R2, '>', $sh_file_R2 or die;
        print $fh_R2 "#!/bin/bash\n";
        print $fh_R2 "#\$ -N cutadapt.R2.$pattern_R2\n";
        print $fh_R2 "#\$ -wd $sh_path\n";
        print $fh_R2 "#\$ -pe smp $threads\n";
        print $fh_R2 "date\n\n";
        
        if ($trim_length < 0) {
            exit print "ERROR!! Check your R1 trimming length!!!";
        }elsif ($trim_length == 0){
            print $fh_R2 "ln -s $id $output_path/$pattern_R2\n";
#            print $fh_R2 "$faster $output_path/$pattern_R2\n";
        }else {
            print $fh_R2 "$program -u -$trim_length -o $output_path/$pattern_R2 $id \n";
#            print $fh_R2 "$faster $output_path/$pattern_R2\n";
        }
    print $fh_R2 "date\n";
    close $fh_R2;
    cmd_system ($sh_path, $hostname, $sh_file_R2);
    }
} 

