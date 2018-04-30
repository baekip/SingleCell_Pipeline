#!/usr/bin/perl

=head1 Name
    
    pipeline.pl -- iSAAC WGS pipeline script

=head1 Version
    
    Author: baekip (inpyo.baek@theragenetex.com)
    Version: 0.1
    Date: 2017-02-21

=head1 Usage

    perl pipeline.pl [option] file
        -c: input config <wgs.config.txt>
        -p: input pipeline <wgs.pipeline.txt>
        -h: output help information to screen

=head1 Subscript

    - isaac_pre.pl, 2017-02-21
    - fastqc.pl, 2017-02-22
    - isaac.pl, 2017-02-22

=head1 Example

    perl pipeline -c wgs.config.txt -p wgs.pipeline.txt

=cut

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd qw(abs_path);
use lib dirname(abs_path $0) . '/../library';
use Utils qw (read_config checkFile make_dir checkDir trim);
use Data::Dumper;

my ($config, $pipeline, $help);
GetOptions (
    'config=s' => \$config,
    'pipeline=s' => \$pipeline,
    'help=s' => \$help
);

$pipeline = (abs_path $pipeline);
$config  = (abs_path $config);

die `pod2text $0` if (!defined $config || !defined $pipeline || $help);

my %info;
read_config ($config, \%info);
my $delivery_tbi_id = $info{delivery_tbi_id};
my @id_list = split /\,/, $delivery_tbi_id;
my @input_value;
foreach (@input_value){
    my ($delivery_id, $tbi_id, $type_id) = split /:/, $_;
}
my $title = 'Sample Information';

my @table_info;
my @header_list = ("No.", "Delivery ID", "TBI ID", "Note");
table_header($title, @header_list);
table_body(@id_list);
#table header
sub table_header {
    my ($name, @value) = @_;
<<EOT;
<a name="$name"></a>
<h1>$name</h1>
<table>
    <tr>
EOT
    
    for (my $i=0; $i<@value; $i++){
        my $j = $i + 1;
        if ($j == 1) {
            print "\t<th class=\"first\"><strong>$value[$i]<strong></th>\n";
        }else{
            print "\t<th>$value[$i]</th>\n";
        }
    }
}
#table body
sub table_body {
    my @value = @_;
    print scalar @value;
    for (my $i=0; $i<@value; $i++){
        my $j = $i+1;
        my @tmp_value = split /\:/,$value[$i];
        print "</tr>\n";
        if ($j % 2 == 1) {
            print "\t<tr class=\"row-a\">\n";
        }elsif ($j % 2 == 0){
            print "\t<tr class=\"row-b\">\n";
        }
        print "\t<td class=\"first\">$j</td>\n";
        foreach my $sub_value (@tmp_value){
            print "\t\t<td>$sub_value</td>\n";
        }
    }
    print "</tr>\n";
    print "</table>\n";
}
#my $check_1;
#$check_1->{config}{config_test} = "test"; ##same: $check_1->{config}->{config_test} = "test";
#print Dumper ($check_1) ."\n";
#print keys (%{$check_1})."\n";
#
#foreach my $name ( sort keys %$check_1){
#    print $name."\n";
#    foreach my $subject (keys %{$check_1->{$name}}){
#        print "$name, $subject: $check_1->{$name}{$subject}\n";
#    }
#}
#

#my %check_2;
#$check_2{config}{config_test} = "test";
#print Dumper (\%check_2)."\n";
#print keys (%check_2)."\n";
#
#foreach my $name ( sort keys %check_2){
#    print $name."\n";
#    foreach my $subject (keys %{$check_2{$name}}){
#        print "$name, $subject: $check_2{$name}{$subject}\n";
#    }
#}

#for my $name ( sort keys %$check){
#    for my $subject (keys %{$check{$name}}){
#        print "$name, $subject: $check{$name}{$subject}\n";
#    }
#}

#print $check{config}."\n";

#my %pipe;
#read_pipeline ($pipeline, \%pipe);

#############################################################
#Requirement config source 
#############################################################

my $pipeline_path = dirname (abs_path $0);
my $script_path = "$pipeline_path/script/";
my $project_path = $info{project_path};
my $rawdata_path = $info{rawdata_path};
my $result_path = $info{result_path};
my $report_path = $info{report_path};
my $project_id = $info{project_id};
my $sample_id = $info{sample_id};
my $sh_path = sprintf ('%s/sh_log_file', $result_path);
my $flag_orig_path = sprintf ('%s/flag_file/', $result_path);
my @sample_list = split /\,/, $sample_id;
#checkDir ($script_path);
make_dir($result_path);
make_dir($report_path);
make_dir($sh_path);
make_dir($flag_orig_path);
#############################################################
#Requirement config source 
#############################################################

read_pipeline_config ($config, $pipeline);


my @pipe_list;
sub read_pipeline_config{
    my ($config_config, $pipeline_config) = @_;
    open my $fh_pipe, '<:encoding(UTF-8)', $pipeline_config or die;
    while (my $row = <$fh_pipe>){
        chomp $row;
        if ($row =~ /^#|^\s+/) {next;}
        if (length $row == 0) {next;}
        push @pipe_list, $row;
    }
    close $fh_pipe;
}

my %pipe_hash;
pipe_arrange ($pipeline, \%pipe_hash);

sub pipe_arrange { 
    my ($pipe, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $pipe or die;
    while (my $row = <$fh>) {
        chomp $row; 
        if ($row =~ /^#|^\s+/){next;}
        if (length ($row) == 0){next;}
        my ($order, $input_order, $program, $option, $type, $threads) = split /\s+/, $row;
        if ($option =~ /,/){
            my @option_list = split /\,/, $option;
            $option = $option_list[0];
        }else {}

        my $run_name = sprintf ("%s_%s_%s", $order, $program, $option);
        $hash_ref->{$order}=$run_name;
    }
}

=cut
foreach my $row (@pipe_list){
    my $input_path;
    my ($order, $input_order, $program, $option, $type, $threads) = split /\s+/, $row;
    if ($option =~ /,/){
        my @option_list = split /\,/, $option;
        $option = $option_list[0];
    }else{ }

    if ($input_order =~ /,/){
        my @input_list = split /\,/, $input_order;
    }else{ }

    if ($input_order eq '00'){ 
        $input_path = $rawdata_path; 
    }else {
        $input_path = sprintf ("%s/%s_%s_%s", $result_path, $order, $program, $option);
    }
   
###flag start
    my $script = sprintf ("%s/%s.pl", $script_path, $program);
    my $output_path = sprintf ("%s/%s_%s_%s", $result_path, $order, $program, $option);
    my $sh_program_path = sprintf ("%s/%s_%s_%s/", $sh_path, $order, $program, $option);
    

    foreach my $sample (@sample_list){
        if ($type eq 'private'){
            my $program_bin = 'perl_script';
            program_run($script, $program_bin, $input_path, $sample, $sh_program_path, $output_path, $threads, $config);
        }elsif ($type eq 'public'){
            my $program_bin = $info{$program};
            program_run ($script, $program_bin, $input_path, $sample, $sh_program_path, $output_path, $threads, $config);
        }else {
            die "ERROR!! Check your pipeline configre <Order Number: $order> type option";
        }
    }

    my $flag_path = sprintf ("%s/%s_%s_%s", $flag_orig_path, $order, $program, $option);
    make_dir($flag_path);
    my $flag_file = sprintf ("%s/%s_%s_%s_flag.txt", $flag_path, $order, $program, $option);

}


sub program_run {
    my $datestring=localtime();
    print "-------------------------------------------------------\n";
    print "Start: $datestring\n";
    print "-------------------------------------------------------\n";
    
    my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $config) = @_;
    $input_path = sprintf ("%s/%s", $input_path, $sample);
    $sh_path = sprintf ("%s/%s/", $sh_path, $sample);
    $output_path = sprintf ("%s/%s/", $output_path, $sample);
    checkFile($script);
    make_dir($output_path);
    
    my $cmd = "perl $script -p $program -i $input_path -S $sample -l $sh_path -o $output_path -t $threads -c $config";
    print $cmd."\n";
    system($cmd);
}
=pod

#    my ($program, $input_path, $sample, $log_path, $output_path, $threads, $config);
#    GetOptions (
#    'program|p=s' => \$program,
#    'input_path|i=s' => \$input_path,
#    'sample|s=s' => \$sample,
#    'log_path|l=s' => \$log_path,
#    'output_path|o=s' => \$output_path,
#    'threads|t=s' => \$threads,
#    'config_file|c=s' => \$config,
#     );






#sub run_pipeline {
#    my ($dic_flow_pipeline, $list_flow_pipeline, $config_file, $pipeline_file) = @_;
    

#sub program_run {
#    my ($list_run, $list_sample_id, $program_script, $project_log_write_fp);
#    print "\n";
#    print "=======================================================\n";
#    print "-------START : $program_
#


