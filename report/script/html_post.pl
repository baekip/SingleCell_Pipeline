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
use Report_Utils qw(templ_files templ_sidebar table_header table_body table_post_1 table_post_2 table_main);
use Report_Graphics qw(graphics_stack_hist graphics_clumn_hist graphics_boxplot);
use Utils qw(checkDir read_config trim checkFile make_dir num); 

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
my $ver = $info{version};
my $project_id = $info{project_id};
my $rawdata_path = $info{rawdata_path};
my $project_path = $info{project_path};
my $report_path = $info{report_path};
my $dev_path = $info{dev_path};
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $pair_id = $info{pair_id};
my @pair_list = split /,/, $pair_id;
my $orig_images = "$dev_path/report/images";
checkDir($orig_images);
my $filt_param = $info{filt_param};
my $scRNA_report = "$report_path/scRNA_report";
my $seq_stat = "$scRNA_report/overview/Sequencing_Statistics_Result.xls";
checkFile($seq_stat);

#############################################################
#make Post Processing Tab (postprocessing_index.html) 
#############################################################
my $post_dir = "$scRNA_report/post_processing";
make_dir($post_dir);

my ($first_path, $second_path, $third_path, $fourth_path, $fifth_path, $sixth_path) = split /\,/, $input_path;

### option specific information
my ($gene, $umi, $mito) = split /\,/, $filt_param;
my ($min_gene, $max_gene) = split /\-/, $gene;
my ($min_umi, $max_umi) = split /\-/, $umi;
my ($min_mito, $max_mito) = split /\-/, $mito;
my $param_templ = "$min_gene\_$max_gene\_$min_umi\_$max_umi\_$min_mito\_$max_mito";
my (@filt_value, @filt_base_value);
push @filt_value, "nGene:$min_gene:$max_gene";
push @filt_value, "nUMI:$min_umi:$max_umi";
push @filt_value, "percentage of mitochondria RNA:$min_mito:$max_mito";

my $fc_stat = "$post_dir/filt.cells.txt";
open my $f_fc, '>', $fc_stat or die;
my $at_stat = "$post_dir/filt.total.at.least.one.txt";
open my $f_at, '>', $at_stat or die;
my $exp_stat = "$post_dir/filt.total.expression.sum.per.cell.txt";
open my $f_exp, '>', $exp_stat or die;


print $f_fc "TBI_ID\tDelivery_ID\tFALSE\tTRUE\tTotal\n";
print $f_at "TBI_ID\tDelivery_ID\tMin\t1st_Qu\tMedian\tMean\t3rd_Qu\tMax\n";
print $f_exp "TBI_ID\tDelivery_ID\tMin\t1st_Qu\tMedian\tMean\t3rd_Qu\tMax\n";

my %hash;
my (@tra_sample, @tra_pair, @delivery_pair, @post_sidebar, @fc_value);
foreach my $id (@delivery_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    $hash{$tbi_id}{delivery_id} = $delivery_id;
    push @tra_sample, $delivery_id;
}

if (scalar @pair_list > 0){
    foreach my $id (@pair_list) {
        if ($id =~ /_/){
            my @id_list = split /_/, $id;
            my @trans_id;
        
            foreach my $sub_id (@id_list) {
                push @trans_id, $hash{$sub_id}{delivery_id};
            }
   
            my $tra_id = join ('_', @trans_id);
            push @delivery_pair, "$tra_id:$id:.";
            push @tra_pair, $tra_id;
        }
    }
}

parsing_contents ($fifth_path, \@delivery_list, \@post_sidebar, \@fc_value);
parsing_contents ($sixth_path, \@delivery_pair, \@post_sidebar, \@fc_value);

sub parsing_contents {
    my ($in_path, $in_list, $in_side, $in_value) = @_;
    
    foreach my $id (@$in_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
        push @$in_side, "$delivery_id\_postprocessing.html:$delivery_id";
        my $filt_post_path = "$in_path/$tbi_id/$param_templ/Filt";
        checkDir($filt_post_path);
        my $basic_post_path = "$in_path/$tbi_id/$param_templ/Basic";
        checkDir($basic_post_path);

#    my $gene_png = "$post_path/Filtered_Distribution_of_detected_genes.png";
#    my $exp_png = "$post_path/Filtered_Expresssion_sum_per_cell.png";
        my $norm_png = "$filt_post_path/Filtered_normalisation_distribution.png";
        my $dispersion_png = "$filt_post_path/Filtered_gene_dispersion.png";
        my $vlnplot_png = "$filt_post_path/Filtered_vlnplot.png";
        my $geneplot_png = "$filt_post_path/Filtered_Geneplot.png";

        my $sub_post_dir = "$post_dir/$delivery_id";
        make_dir($sub_post_dir);

        system ("cp $basic_post_path/* $sub_post_dir");
#    copy_file ($gene_png, $sub_post_dir);
#    copy_file ($exp_png, $sub_post_dir);
        copy_file ($norm_png, $sub_post_dir);
        copy_file ($dispersion_png, $sub_post_dir);
        copy_file ($vlnplot_png, $sub_post_dir);
        copy_file ($geneplot_png, $sub_post_dir);
   
        my $filtcells = "$filt_post_path/FiltCells.txt";
        checkFile($filtcells);
        my $at_least_file = "$filt_post_path/Filtered.at.least.one.txt";
        checkFile($at_least_file);
        my $exp_file = "$filt_post_path/Filtered.expression.sum.per.cell.txt";
        checkFile($exp_file);
        
        open my $fh_fc, '<:encoding(UTF-8)', $filtcells or die;
        my $false_fc = <$fh_fc>;
        chomp ($false_fc);
        my ($false, $false_cell) = split /\s+/, trim($false_fc);
        my $true_fc = <$fh_fc>;
        my ($ture, $true_cell) = split /\s+/, trim($true_fc);
        my $total_cell = trim($false_cell) + trim($true_cell);
        $false_cell = num($false_cell);
        $true_cell = num($true_cell);
        $total_cell = num($total_cell);
        push @$in_value, "$delivery_id:$false_cell:$true_cell:$total_cell";
        
        print $f_fc "$tbi_id\t$delivery_id\t$false_cell\t$true_cell\t$total_cell\n";


        open my $fh_at, '<:encoding(UTF-8)', $at_least_file or die;
        my $header_at = <$fh_at>;
        chomp ($header_at);
        my $row_at = <$fh_at>;
        my ($min_at, $first_at, $median_at, $mean_at, $third_at, $max_at) = split /\s+/, trim($row_at);
        
        print $f_at "$tbi_id\t$delivery_id\t$min_at\t$first_at\t$median_at\t$mean_at\t$third_at\t$max_at\n";

        open my $fh_at_exp, '<:encoding(UTF-8)', $exp_file or die;
        my $header_at_exp = <$fh_at_exp>;
        chomp ($header_at_exp);
        my $row_exp = <$fh_at_exp>;
        my ($min_exp, $first_exp, $median_exp, $mean_exp, $third_exp, $max_exp) = split /\s+/, trim($row_exp);

        print $f_exp "$tbi_id\t$delivery_id\t$min_exp\t$first_exp\t$median_exp\t$mean_exp\t$third_exp\t$max_exp\n";
    }
}
close $f_fc;
close $f_at;
close $f_exp;

foreach my $id (@tra_sample){
    ###make sub postprocessing html
    my $sub_post_html = "$post_dir/$id\_postprocessing.html";
    
    open my $fh_sub_post, '>', $sub_post_html or die;
    print $fh_sub_post TEMPL_HTML_HEAD("..");
    print $fh_sub_post TEMPL_HEADER($sub_post_html);
    print $fh_sub_post TEMPL_MENU("..");
    templ_sidebar($fh_sub_post, @post_sidebar);
    table_post_1($fh_sub_post, $id);
    table_post_2($fh_sub_post, $id);
    print $fh_sub_post TEMPL_FOOTER_2("..");
    print $fh_sub_post TEMPL_HTML_FOOTER;
    close $fh_sub_post;
}

foreach my $id (@tra_pair){
    ###make sub postprocessing html
    my $sub_post_html = "$post_dir/$id\_postprocessing.html";
    
    open my $fh_sub_post, '>', $sub_post_html or die;
    print $fh_sub_post TEMPL_HTML_HEAD("..");
    print $fh_sub_post TEMPL_HEADER($sub_post_html);
    print $fh_sub_post TEMPL_MENU("..");
    templ_sidebar($fh_sub_post, @post_sidebar);
    table_post_1($fh_sub_post, $id);
    table_post_2($fh_sub_post, $id);
    print $fh_sub_post TEMPL_FOOTER_2("..");
    print $fh_sub_post TEMPL_HTML_FOOTER;
    close $fh_sub_post;
}

#############################################################
#make PostProcessing Tab (processing_index.html) 
#############################################################
my $html_post = "$post_dir/postprocessing_index.html";
open my $fh_post, '>', $html_post or die;

my @filt_header_list = ("No.", "Feature", "Min", "Max");
my @fc_header_list = ("No.", "Delivery ID", "FALSE<br>Cells", "TRUE<br>Cells", "Total<br>Cells");

print $fh_post TEMPL_HTML_HEAD("..");
print $fh_post TEMPL_HEADER($html_post);
print $fh_post TEMPL_MENU("..");
templ_sidebar($fh_post, @post_sidebar);
###FilterCriteria
table_header ($fh_post, 'Filtration Information', @filt_header_list);
table_body ($fh_post, @filt_value);
###FilterCells
table_header ($fh_post, 'Filtration of Cells', @fc_header_list);
table_body ($fh_post, @fc_value);
###Main figure
foreach my $id (@tra_sample){
    table_main ($fh_post, $id)
}
foreach my $id (@tra_pair){
    table_main ($fh_post, $id)
}

print $fh_post TEMPL_FOOTER_2("..");
print $fh_post TEMPL_HTML_FOOTER;
close $fh_post;


sub copy_file {
    my ($file, $copy_file) = @_;
    checkFile ($file);
    my $cmd = "cp $file $copy_file";
    system ($cmd);
}
