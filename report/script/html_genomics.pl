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
my @delivery_list = split /\,/, $delivery_tbi_id;
my $pair_id = $info{pair_id};
my @pair_list = split /\,/, $pair_id;
my $ver = $info{version};
my $orig_images = "$dev_path/report/images";
checkDir($orig_images);
my $scRNA_report = "$report_path/scRNA_report";
my $seq_stat = "$scRNA_report/overview/Sequencing_Statistics_Result.xls";
checkFile($seq_stat);
my $mapping_stat = "$scRNA_report/overview/total.mapping.xls";
checkFile($mapping_stat);

#############################################################
#make Overview Tab (overview.html) 
#############################################################
my $genomics_dir = "$scRNA_report/10XGenomics_result";
make_dir ($genomics_dir);
my ($first_path, $second_path, $third_path, $fourth_path, $fifth_path, $sixth_path) = split /\,/, $input_path;

my %hash;
my (@tra_sample, @tra_pair, @genomics_sidebar);
foreach my $id (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    $hash{$tbi_id}{delivery_id}=$delivery_id;
    push @tra_sample, $delivery_id;
    push @genomics_sidebar, "#$delivery_id:$delivery_id";

    my $cellranger_path = "$second_path/$tbi_id/$tbi_id/outs";
    checkDir($cellranger_path);
    my $sub_genomics_dir = "$genomics_dir/$delivery_id";
    make_dir($sub_genomics_dir);

    my $web_summary = "$cellranger_path/web_summary.html";
    my $cloupe_file = "$cellranger_path/cloupe.cloupe";
    copy_file ($web_summary, $sub_genomics_dir);
    copy_file ($cloupe_file, $sub_genomics_dir);
}

foreach my $id (@pair_list){
    my $cellranger_path = "$fourth_path/$id/$id/outs";
    checkDir($cellranger_path);
    
    if ($id =~ /_/){
        my @id_list = split /_/, $id;
        my @trans_id;
        
        foreach my $sub_id (@id_list) {
            push @trans_id, $hash{$sub_id}{delivery_id};
        }
   
        my $tra_id = join ('_', @trans_id);
        
        push @tra_pair, $tra_id;
        push @genomics_sidebar, "#$tra_id:$tra_id";
        
        my $sub_genomics_dir = "$genomics_dir/$tra_id";
        make_dir ($sub_genomics_dir);
        my $web_summary = "$cellranger_path/web_summary.html";
        my $cloupe_file = "$cellranger_path/cloupe.cloupe";
        copy_file ($web_summary, $sub_genomics_dir);
        copy_file ($cloupe_file, $sub_genomics_dir);

    }elsif ($id =~ /ALL/){
        push @tra_pair, $id;
        push @genomics_sidebar, "#$id:$id";
        my $sub_genomics_dir = "$genomics_dir/$id";
        make_dir ($sub_genomics_dir);
        my $web_summary = "$cellranger_path/web_summary.html";
        my $cloupe_file = "$cellranger_path/cloupe.cloupe";
        copy_file ($web_summary, $sub_genomics_dir);
        copy_file ($cloupe_file, $sub_genomics_dir);
    }
}



my $html_genomics = "$genomics_dir/10XGenomics_index.html";
open my $fh_genomics, '>', $html_genomics or die;
print $fh_genomics TEMPL_HTML_HEAD("..");
print $fh_genomics TEMPL_HEADER($html_genomics);
print $fh_genomics TEMPL_MENU("..");
templ_sidebar($fh_genomics, @genomics_sidebar);
print $fh_genomics TEMPL_10X;
templ_box_10X ($fh_genomics, @tra_sample); 
templ_box_10X ($fh_genomics, @tra_pair);
print $fh_genomics TEMPL_FOOTER_2("..");
print $fh_genomics TEMPL_HTML_FOOTER;
close $fh_genomics;

sub copy_file {
    my ($file, $copy_file) = @_;
    checkFile ($file);
    my $cmd = "cp $file $copy_file";
    system ($cmd);
}
