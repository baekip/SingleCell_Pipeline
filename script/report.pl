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

#######################Requirement########################
my %info;
my $sh_file = sprintf ('%s/%s', $sh_path, "report.$sample.sh");
read_config ($config_file, \%info);

my $project_path = $info{project_path};
my $dev_path = $info{dev_path};
my $script_path = "$dev_path/report/script";

### make stat result file 

#######
open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N report.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";

print $fh_sh "perl $script_path/sc_report.pl -c $config_file -o $output_path -i $input_path\n"; 

print $fh_sh "date\n";
close $fh_sh;

cmd_system ($sh_path, $hostname, $sh_file);

sub match_id {
    my ($id_list, $hash_ref) = @_;
    my @id_array = split /\,/, $id_list;
    foreach my $id (@id_array){
        my ($delivery_id, $tbi_id, $type) = split /\:/, $id;
        $hash_ref->{$tbi_id}=$delivery_id;
    }
}

