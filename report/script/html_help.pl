#############################################################
#CNVkit report V0.3.1
#Date - 2017.01.13
#Author - baekip
#############################################################
#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname (abs_path $0) . '/../library';
use Report qw(TEMPL_HTML_HEAD TEMPL_HEADER TEMPL_MENU TEMPL_TBI TEMPL_10X TEMPL_HELP TEMPL_SIDEBAR TEMPL_FOOTER TEMPL_HELP TEMPL_FOOTER_2 TEMPL_HTML_FOOTER);
use Report_Utils qw(templ_files templ_box_10X templ_sidebar table_header table_body table_scQC);
use Utils qw(checkDir read_config trim checkFile make_dir); 

my ($in_config, $input_path, $output_path);
GetOptions(
    'config=s' => \$in_config,
    'output_path=s' => \$output_path,
    'input_path=s' => \$input_path,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option \n";
}

my %info;
read_config($in_config, \%info);

#############################################################
#Requirement 
#############################################################
my $script_path = dirname(abs_path $0);
my $project_id = $info{project_id};
my $rawdata_path = $info{rawdata_path};
my $project_path = $info{project_path};
my $report_path = $info{report_path};
my $dev_path = $info{dev_path};
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;
my $ver = $info{version};
my $orig_images = "$dev_path/report/images";
checkDir($orig_images);
my $scRNA_report = "$report_path/scRNA_report";

#############################################################
#make Overview Tab (overview.html) 
#############################################################
my $help_dir = "$scRNA_report/help";
make_dir ($help_dir);

my @help_sidebar = ("#Sequencing Quality:Sequencing Quality", "#Method:Method");

my $html_help = "$help_dir/help_index.html";
open my $fh_help, '>', $html_help or die;
print $fh_help TEMPL_HTML_HEAD("..");
print $fh_help TEMPL_HEADER($html_help);
print $fh_help TEMPL_MENU("..");
templ_sidebar($fh_help, @help_sidebar);
print $fh_help TEMPL_HELP;
print $fh_help TEMPL_FOOTER_2("..");
print $fh_help TEMPL_HTML_FOOTER;
close $fh_help;

sub copy_file {
    my ($file, $copy_file) = @_;
    checkFile ($file);
    my $cmd = "cp $file $copy_file";
    system ($cmd);
}
