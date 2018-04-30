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
use Report_Utils qw(templ_files templ_sidebar table_header table_body);
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
my $scRNA_report = "$report_path/scRNA_report";
my $raw_stat = "$rawdata_path/Sequencing_Statistics_Result.xls";
checkFile($raw_stat);
use Data::Dumper;
my $overview_dir = "$scRNA_report/overview";
make_dir ($overview_dir);

#############################################################
#make stat file
#############################################################
my ($first_path, $second_path, $third_path, $fourth_path, $fifth_path) = split /\,/, $input_path;
system ("cp $raw_stat $overview_dir");
my $mapping_stat = "$overview_dir/total.mapping.xls";
system ("cat $third_path/*/*xls | sort -u > $mapping_stat");
my $at_stat = "$overview_dir/total.at.least.one.txt";
open my $f_at, '>', $at_stat or die;
my $exp_stat = "$overview_dir/total.expression.sum.per.cell.txt";
open my $f_exp, '>', $exp_stat or die;

print $f_at "TBI_ID\tDelivery_ID\tMin\t1st_Qu\tMedian\tMean\t3rd_Qu\tMax\n";
print $f_exp "TBI_ID\tDelivery_ID\tMin\t1st_Qu\tMedian\tMean\t3rd_Qu\tMax\n";

my (%at_genes, %at_exp);
foreach my $id (@delivery_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $QC_path = "$fifth_path/$tbi_id/QC";
    my $at_least_file = "$QC_path/at.least.one.txt";
    checkFile($at_least_file);
    my $exp_file = "$QC_path/expression.sum.per.cell.txt";
    checkFile($exp_file);

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

close $f_at;
close $f_exp;



#############################################################
#make Overview Tab (overview.html) 
#############################################################

my $seq_stat = "$scRNA_report/overview/Sequencing_Statistics_Result.xls";
checkFile($seq_stat);
my $gene_stat = "$scRNA_report/overview/total.at.least.one.txt";
checkFile($gene_stat);

my %seq;
open my $fh_seq, '<:encoding(UTF-8)', $seq_stat or die;
my $header_seq = <$fh_seq>;
chomp ($header_seq);
my @headers_seq = split ('\t', $header_seq);

while (my $row = <$fh_seq>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[0];
    my $sub_seq = $row_list[2];
    my $tmp_sample = "$sample_id\_$sub_seq";
    for my $header (@headers_seq){
        push (@{$seq{$tmp_sample}{$header}}, shift(@row_list));
    }
}
my @sample_list = split /\,/, $info{delivery_tbi_id};
my @sub_seq = ('I1', 'R1', 'R2');
push ((my @stack_overview), "Delivery ID:Index(Gb):R1(Gb):R2(Gb)");
foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    push my (@base_value), $delivery_id;
    foreach (@sub_seq) {
        my $tmp_id = "$tbi_id\_$_";
        my $total_base = join('', @{$seq{$tmp_id}{'TotalBases(Gb)'}});
        $total_base =~ s/\s+Gb//g;
        push @base_value, $total_base;
    }
    push @stack_overview, join (':', @base_value);
}

my %map;
open my $fh_map, '<:encoding(UTF-8)', $mapping_stat or die;
my $header_map = <$fh_map>;
chomp ($header_map);
my @headers_map = split ('\t', $header_map);

while (my $row = <$fh_map>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[0];
    for my $header (@headers_map){
        push (@{$map{$sample_id}{$header}}, shift(@row_list));
    }
}

push ((my @clumn_overview) , "Delivery ID:Exonic Regions:Transciptome:Intronic Regions:Intergenic Regions");
foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    push my (@base_value), $delivery_id;
    my $exonic = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Exonic Regions'}});
    $exonic =~ s/%//g;
    my $transcriptome = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Transcriptome'}});
    $transcriptome =~ s/%//g;
    my $intronic = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Intronic Regions'}});
    $intronic =~ s/%//g;
    my $intergenic = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Intergenic Regions'}});
    $intergenic =~ s/%//g;
    
    push @base_value, $exonic, $transcriptome, $intronic, $intergenic;
    push @clumn_overview, join (':', @base_value);
}


my %gene;
open my $fh_gene, '<:encoding(UTF-8)', $gene_stat or die;
my $header_gene = <$fh_gene>;
chomp ($header_gene);
my @headers_gene = split ('\t', $header_gene);

while (my $row = <$fh_gene>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[0];
    for my $header (@headers_gene){
        push (@{$gene{$sample_id}{$header}}, shift(@row_list));
    }
}

my (@delivery_gene_list,@gene_overview);
my @sub_type = ('Min', '1st_Qu', 'Median', 'Mean', '3rd_Qu', 'Max');
foreach my $temp_type (@sub_type) {
    push my (@base_value), $temp_type;
    foreach my $id (@sample_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
        my $temp = join('', @{$gene{$tbi_id}{$temp_type}});
        push @base_value, $temp;
    }
    push @gene_overview, join (':', @base_value);
}

foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $temp_id = join('',@{$gene{$tbi_id}{Delivery_ID}});
    push @delivery_gene_list, $temp_id;
}


my %exp;
open my $fh_exp, '<:encoding(UTF-8)', $exp_stat or die;
my $header_exp = <$fh_exp>;
chomp ($header_exp);
my @headers_exp = split ('\t', $header_exp);

while (my $row = <$fh_exp>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[0];
    for my $header (@headers_gene){
        push (@{$exp{$sample_id}{$header}}, shift(@row_list));
    }
}

my (@delivery_exp_list, @exp_overview);
foreach my $temp_type (@sub_type) {
    push my (@base_value), $temp_type;
    foreach my $id (@sample_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
        my $temp = join('', @{$exp{$tbi_id}{$temp_type}});
        push @base_value, $temp;
    }
    push @exp_overview, join (':', @base_value);
}

foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $temp_id = join('',@{$exp{$tbi_id}{Delivery_ID}});
    push @delivery_exp_list, $temp_id;
}
#foreach my $name (sort keys %combined){
#    my $total_seq = join('', @{$combined{$name}{'TotalBases(Gb)'}});
#    $total_seq =~ s/\s+Gb//g;
#    print $total_seq."\n";
#}
my @overview_sidebar = ("#Files:Files", "#Sequencing_Statistics:Sequencing Statistics", "#Alignment_Statistics:Alignment Statistics");
my @overview_files = ("Sequencing Statistics File:./Sequencing_Statistics_Result.xls", "Alignmnet Statistics File:./alignment.statstics.xls");

my $html_overview = "$overview_dir/overview_index.html";
open my $fh_overview, '>', $html_overview or die;
print $fh_overview TEMPL_HTML_HEAD("..");
print $fh_overview TEMPL_HEADER($html_overview);
print $fh_overview TEMPL_MENU("..");
templ_sidebar($fh_overview, @overview_sidebar);
templ_files($fh_overview, @overview_files);
graphics_stack_hist ($fh_overview, 'Summary_for_Produced_Sequencing_Data', 'Sequencing_Statistics', @stack_overview);
graphics_clumn_hist ($fh_overview, 'Mapping_Summary_for_Profuced_Sequenicng_Data', 'Alignment_Statistics', @clumn_overview);
graphics_boxplot ($fh_overview, 'Detected genes perl cell','Detected genes per cell', \@gene_overview, \@delivery_gene_list);
graphics_boxplot ($fh_overview, 'Expression Sum per cell', 'Expression Sum per cell',  \@exp_overview, \@delivery_exp_list);
print $fh_overview TEMPL_FOOTER_2("..");
print $fh_overview TEMPL_HTML_FOOTER;
close $fh_overview;

