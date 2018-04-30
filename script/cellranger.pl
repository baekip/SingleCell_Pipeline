#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir trim checkFile read_config cmd_system);
use Data::Dumper;

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


my %info;
my $sh_file = sprintf ('%s/%s', $sh_path, "cellranger.$option.$sample.sh");
read_config ($config_file, \%info);
my $cellranger_reference = $info{cellranger_reference};
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id; 

my %hash;
foreach my $id (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    $hash{$tbi_id}{delivery_id}=$delivery_id;
}

my $local_mem;
if ($threads =~ /,/){
    ($threads, $local_mem) = split /\,/, $threads;
}else{
    $local_mem = 16;
}

open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N cellranger.$option.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
print $fh_sh "date\n\n";
print $fh_sh "cd $output_path\n\n";
if ($option eq "count"){
    
    if (!$hash{$sample}{delivery_id}) {
        exit print "ERROR!! Check your value of <sample_id> or <delivery_tbi_id> !!\n";
    }else {
        print $fh_sh "$program count \\
            --id=$sample \\
            --transcriptome=$cellranger_reference \\
            --fastqs=$input_path \\
            --sample=$sample \\
            --localmem=$local_mem \n\n";
#            --id=$hash{$sample}{delivery_id}\\
    }
    
}elsif ($option =~ /aggr/){
    my $library_csv = "$output_path/$sample.library.csv";
    open my $fh_csv, '>', $library_csv or die;
    print $fh_csv "library_id,molecule_h5\n";
        
    if ($sample =~ /_/){
        my @id_list = split /_/, $sample;
        foreach my $sub_id (@id_list){
            if (!$hash{$sub_id}{delivery_id}) {
                exit print "ERROR!! Check your value of <sample_id> or <delivery_tbi_id> !!\n";
            }else {
                my $molecule_info = "$input_path/$sub_id/$sub_id/outs/molecule_info.h5";
                checkFile($molecule_info);
                print $fh_csv "$sub_id,$molecule_info\n";
#                print $fh_csv "$hash{$sub_id}{delivery_id},$molecule_info\n";
            }
        }
    }elsif ($sample =~ /ALL/){
        my $sample_id = $info{sample_id};
        my @id_list = split /\,/, $sample_id;
        foreach my $sub_id (@id_list){

            if (!$hash{$sub_id}{delivery_id}) {
                exit print "ERROR!! Check your value of <sample_id> or <delivery_tbi_id> !!\n";
            }else {
                my $molecule_info = "$input_path/$sub_id/$sub_id/outs/molecule_info.h5";
                checkFile($molecule_info);
                print $fh_csv "$sub_id,$molecule_info\n";
#                print $fh_csv "$hash{$sub_id}{delivery_id},$molecule_info\n";
            }
        }
    }else {
        exit print "ERROR!! Check your aggregation value of config file!!!"; 
    }
    close $fh_csv;
    
    print $fh_sh "$program aggr \\
    --id=$sample \\
    --csv=$library_csv \\
    --normalize=mapped \\
    --localmem=$local_mem \n\n";
}

print $fh_sh "date\n";
close $fh_sh;

cmd_system ($sh_path, $hostname, $sh_file);


