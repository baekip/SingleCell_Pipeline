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
use Report qw(TEMPL_HTML_HEAD TEMPL_HEADER TEMPL_MENU TEMPL_TBI TEMPL_SIDEBAR TEMPL_FOOTER TEMPL_FOOTER_2 TEMPL_HTML_FOOTER);
use Report_Utils qw(templ_files templ_box_10X templ_sidebar table_header table_body);
use Report_Graphics qw(graphics_stack_hist graphics_clumn_hist graphics_boxplot);
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
my $ver = $info{version};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $orig_images = "$dev_path/report/images";
checkDir($orig_images);
#############################################################
#make result folder 
#############################################################
my $scRNA_report = "$report_path/scRNA_report";
if (-d $scRNA_report) {
    `rm -r $scRNA_report`;
}
make_dir($scRNA_report);
system ("cp -r $orig_images $scRNA_report");

#############################################################
#make Home Tab (index.html) 
#############################################################
my $reference_build = $info{reference_build};
my $kit = $info{kit_type};
my $html_index = "$scRNA_report/index.html";
my @reference_header_list = ("No.", "Information", "Description");
my @reference_value = ("Report Version:$ver", "Project ID:$project_id", "Reference:$reference_build", "Platform:<a href=\"https://support.10xgenomics.com/single-cell-gene-expression\" target=\"_blank\">10X Chromium</a>", "Library Prep Kit:<a href=\"https://support.10xgenomics.com/single-cell-gene-expression/library-prep\" target=\"_blank\">$kit</a>");
my @sample_header_list = ("No.", "Delivery ID", "TBI ID", "Note");
my @index_sidebar = ("#Theragen Etex Bio Institute:Theragen Info", "#Reference Genome:Reference Genome", "#Sample Information:Sample Information");

open my $fh_index, '>', $html_index or die;
print $fh_index TEMPL_HTML_HEAD(".");
print $fh_index TEMPL_HEADER($html_index);
print $fh_index TEMPL_MENU(".");
templ_sidebar($fh_index, @index_sidebar);
print $fh_index TEMPL_TBI;
table_header($fh_index, 'Project Information', @reference_header_list);
table_body($fh_index, @reference_value);
table_header($fh_index, 'Sample Information', @sample_header_list); 
table_body($fh_index, @delivery_list);
print $fh_index TEMPL_FOOTER(".");
print $fh_index TEMPL_HTML_FOOTER;
close $fh_index;


#############################################################
#make Overview Tab (overview.html) 
#############################################################
my $cmd_overview = "perl $dev_path/report/script/html_overview.pl -c $in_config -o $output_path -i $input_path";
system($cmd_overview);


##############################################################
##make Sample Tab (sample.html) 
##############################################################
my $cmd_samples = "perl $dev_path/report/script/html_samples.pl -c $in_config -o $output_path -i $input_path";
system($cmd_samples);


#############################################################
#make Mapping Tab (mapping.html) 
#############################################################
my $cmd_mapping = "perl $dev_path/report/script/html_mapping.pl -c $in_config -o $output_path -i $input_path";
system($cmd_mapping);

#############################################################
#make 10X Genomics Report (10XGenomics_index.html)
#############################################################
my $cmd_genomics = "perl $dev_path/report/script/html_genomics.pl -c $in_config -o $output_path -i $input_path";
system($cmd_genomics);

#############################################################
#make scQC Result (scQC_index.html)
#############################################################
my $cmd_scQC = "perl $dev_path/report/script/html_scQC.pl -c $in_config -o $output_path -i $input_path";
system($cmd_scQC);

#############################################################
#make Post Processing (postprocessing_index.html)
#############################################################
my $cmd_post = "perl $dev_path/report/script/html_post.pl -c $in_config -o $output_path -i $input_path";
system($cmd_post);


#############################################################
#make help (help_index.html)
#############################################################
my $cmd_help = "perl $dev_path/report/script/html_help.pl -c $in_config -o $output_path -i $input_path";
system($cmd_help);

