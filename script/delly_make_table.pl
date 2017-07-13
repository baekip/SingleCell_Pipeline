#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);

my ($input, $output, $option); 

GetOptions (
    'input_vcf|i=s' => \$input,
    'output|o=s' => \$output,
    'option|c=s' => \$option,
);

checkFile ($input);

if ($option eq 'INV'){
    
    open my $INV_fh_input, '<:encoding(UTF-8)', $input or die;
    open my $INV_fh_output, '>', $output or die;

    print $INV_fh_output "breakpoint1:chr\tbreakpoint1:pos\tbreakpoint2:chr\tbreakpoint2:pos\tinversion type\n";

    while (my $row = <$INV_fh_input>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @row_list = split /\s/, $row;
        my $info = $row_list[7];
        my @info_list = split /;/, $info;
        my $breakpoint1_chr = $row_list[0];
        my $breakpoint1_pos = $row_list[1];
        my ($chr_info,$breakpoint2_chr) = split /=/, $info_list[3];
        my ($pos_info,$breakpoint2_pos) = split /=/, $info_list[4];
        my ($ct_info,$trs) = split /=/, $info_list[7];

        print $INV_fh_output "$breakpoint1_chr\t$breakpoint1_pos\t$breakpoint2_chr\t$breakpoint2_pos\t$trs\n";
    }
    close $INV_fh_input;
    close $INV_fh_output;
}elsif ($option eq 'TRA'){

    open my $TRA_fh_input, '<:encoding(UTF-8)', $input or die;
    open my $TRA_fh_output, '>', $output or die;

    print $TRA_fh_output "breakpoint1:chr\tbreakpoint1:pos\tbreakpoint2:chr\tbreakpoint2:pos\ttranslocation type\n";

    while (my $row = <$TRA_fh_input>){
        chomp $row;
        if ($row =~ /^#/) {next;}
        my @row_list = split /\s/, $row;
        my $info = $row_list[7];
        my @info_list = split /;/, $info;
        my $breakpoint1_chr = $row_list[0];
        my $breakpoint1_pos = $row_list[1];
        my ($chr_info,$breakpoint2_chr) = split /=/, $info_list[3];
        my ($pos_info,$breakpoint2_pos) = split /=/, $info_list[4];
        my ($ct_info,$trs) = split /=/, $info_list[7];

        print $TRA_fh_output "$breakpoint1_chr\t$breakpoint1_pos\t$breakpoint2_chr\t$breakpoint2_pos\t$trs\n";
    }
    close $TRA_fh_input;
    close $TRA_fh_output;
}else {
    die "ERROR: Check your option!!";
}

