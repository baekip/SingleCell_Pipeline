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
use Report qw(TEMPL_HTML_HEAD TEMPL_HEADER TEMPL_MENU TEMPL_TBI TEMPL_10X TEMPL_SIDEBAR TEMPL_FOOTER TEMPL_FOOTER_2 TEMPL_HTML_FOOTER);
use Report_Utils qw(templ_files templ_box_10X templ_sidebar table_header table_body table_scQC);
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
my $scQC_dir = "$scRNA_report/scQC_result";
make_dir ($scQC_dir);
my ($first_path, $second_path, $third_path, $fourth_path, $fifth_path, $sixth_path) = split /\,/, $input_path;

my %hash;
my (@tra_sample, @tra_pair, @scQC_sidebar);
foreach my $id (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    $hash{$tbi_id}{delivery_id}=$delivery_id;
    push @scQC_sidebar, "#$delivery_id:$delivery_id";
    push @tra_sample, $delivery_id;
    my $scQC_path = "$fifth_path/$tbi_id/QC";
    checkDir($scQC_path);

    my $gene_png = "$scQC_path/Distribution_of_detected_genes.png";
    checkFile($gene_png);
    my $exp_png = "$scQC_path/Expression_sum_per_cell.png";
    checkFile($exp_png);
    my $geneplot_png = "$scQC_path/Geneplot.png";
    checkFile($geneplot_png);
    my $vlnplot_png = "$scQC_path/vlnplot.png";
    checkFile($vlnplot_png);

    my $sub_scQC_dir = "$scQC_dir/$delivery_id";
    make_dir($sub_scQC_dir);

    copy_file ($gene_png, $sub_scQC_dir);
    copy_file ($exp_png, $sub_scQC_dir);
    copy_file ($geneplot_png, $sub_scQC_dir);
    copy_file ($vlnplot_png, $sub_scQC_dir);
}

foreach my $id (@pair_list){
    my $scQC_path = "$sixth_path/$id/QC";
    checkDir($scQC_path);
    
    if ($id =~ /_/){
        my @id_list = split /_/, $id;
        my @trans_id;
        
        foreach my $sub_id (@id_list) {
            push @trans_id, $hash{$sub_id}{delivery_id};
        }
   
        my $tra_id = join ('_', @trans_id);
        
        push @tra_pair, $tra_id;
        push @scQC_sidebar, "#$tra_id:$tra_id";
        
        my $sub_scQC_dir = "$scQC_dir/$tra_id";
        make_dir ($sub_scQC_dir);
    
    
        my $gene_png = "$scQC_path/Distribution_of_detected_genes.png";
        checkFile($gene_png);
        my $exp_png = "$scQC_path/Expression_sum_per_cell.png";
        checkFile($exp_png);
        my $geneplot_png = "$scQC_path/Geneplot.png";
        checkFile($geneplot_png);
        my $vlnplot_png = "$scQC_path/vlnplot.png";
        checkFile($vlnplot_png);
    
    copy_file ($gene_png, $sub_scQC_dir);
    copy_file ($exp_png, $sub_scQC_dir);
    copy_file ($geneplot_png, $sub_scQC_dir);
    copy_file ($vlnplot_png, $sub_scQC_dir);
    
    }elsif ($id =~ /ALL/){
        push @tra_pair, $id;
        push @scQC_sidebar, "#$id:$id";
        my $sub_scQC_dir = "$scQC_dir/$id";
        make_dir ($sub_scQC_dir);
    }
}

my $html_scQC = "$scQC_dir/scQC_index.html";
open my $fh_scQC, '>', $html_scQC or die;
print $fh_scQC TEMPL_HTML_HEAD("..");
print $fh_scQC TEMPL_HEADER($html_scQC);
print $fh_scQC TEMPL_MENU("..");
templ_sidebar($fh_scQC, @scQC_sidebar);
foreach my $id (@tra_sample) {
    table_scQC($fh_scQC, $id)
}
foreach my $id (@tra_pair){
    table_scQC($fh_scQC, $id)
}
print $fh_scQC TEMPL_FOOTER_2("..");
print $fh_scQC TEMPL_HTML_FOOTER;
close $fh_scQC;

sub copy_file {
    my ($file, $copy_file) = @_;
    checkFile ($file);
    my $cmd = "cp $file $copy_file";
    system ($cmd);
}
