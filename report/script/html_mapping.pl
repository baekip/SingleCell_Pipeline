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
my $seq_stat = "$scRNA_report/overview/Sequencing_Statistics_Result.xls";
checkFile($seq_stat);
my $mapping_stat = "$scRNA_report/overview/total.mapping.xls";
checkFile($mapping_stat);
my $gene_stat = "$scRNA_report/overview/total.at.least.one.txt";
checkFile($gene_stat);
my $exp_stat = "$scRNA_report/overview/total.expression.sum.per.cell.txt";
checkFile($exp_stat);

#############################################################
#make Overview Tab (overview.html) 
#############################################################
use Data::Dumper;
my $overview_dir = "$scRNA_report/overview";
make_dir ($overview_dir);

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
my (@align_value, @cell_value);
push ((my @clumn_overview) , "Delivery ID:Exonic Regions:Transciptome:Intronic Regions:Intergenic Regions");
foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    push my (@base_value), $delivery_id;
    
    my $total_reads = join('', @{$map{$tbi_id}{'Number of Reads'}});
    my $exonic = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Exonic Regions'}});
    my $transcriptome = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Transcriptome'}});
    my $intronic = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Intronic Regions'}});
    my $intergenic = join('', @{$map{$tbi_id}{'Reads Mapped Confidently to Intergenic Regions'}});
    
    push my (@base_align_value), $delivery_id, $total_reads, $exonic, $transcriptome, $intronic, $intergenic;
    push @align_value, join (':', @base_align_value);
    
###make cell overview value
    my $num_cell = join('', @{$map{$tbi_id}{'Estimated Number of Cells'}});
    my $fraction_reads = join('', @{$map{$tbi_id}{'Fraction Reads in Cells'}});
    my $mean_reads = join('', @{$map{$tbi_id}{'Mean Reads per Cell'}});
    my $median_genes = join('', @{$map{$tbi_id}{'Median Genes per Cell'}});
    my $total_genes = join('', @{$map{$tbi_id}{'Total Genes Detected'}});
    my $median_umi =  join('', @{$map{$tbi_id}{'Median UMI Counts per Cell'}});
    
    push my (@base_cell_value), $delivery_id, $num_cell, $fraction_reads, $mean_reads, $median_genes, $total_genes, $median_umi;
    push @cell_value, join (':', @base_cell_value);
    
    $exonic =~ s/%//g;
    $transcriptome =~ s/%//g;
    $intronic =~ s/%//g;
    $intergenic =~ s/%//g;
    
    push @base_value, $exonic, $transcriptome, $intronic, $intergenic;
    push @clumn_overview, join (':', @base_value);
}

my @cell_sub_type = ('Estimated Number of Cells', 'Mean Reads per Cell', 'Median Genes per Cell', 'Total Genes Detected', 'Median UMI Counts per Cell');
my @cell_overview;
foreach my $temp_type (@cell_sub_type) {
    push my (@base_value), $temp_type;
    foreach my $id (@sample_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
        my $temp = join('', @{$map{$tbi_id}{$temp_type}});
        $temp =~ s/\,//g;
        push @base_value, $temp;
    }
    push @cell_overview, join (':', @base_value);
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

my (@delivery_gene_list, @gene_overview, @gene_value);
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

foreach my $id (@sample_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $min = num (join ('', @{$gene{$tbi_id}{'Min'}}));
    my $first_qu = num (join ('', @{$gene{$tbi_id}{'1st_Qu'}}));
    my $median = num (join ('', @{$gene{$tbi_id}{'Median'}}));
    my $mean = num (join ('', @{$gene{$tbi_id}{'Mean'}}));
    my $third_qu = num (join ('', @{$gene{$tbi_id}{'3rd_Qu'}}));
    my $max = num (join ('', @{$gene{$tbi_id}{'Max'}}));
    push my (@base_value), $delivery_id, $min, $first_qu, $median, $mean, $third_qu, $max;
    push @gene_value, join (':', @base_value);
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

my (@delivery_exp_list, @exp_overview, @exp_value);
foreach my $temp_type (@sub_type) {
    push my (@base_value), $temp_type;
    foreach my $id (@sample_list){
        my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
        my $temp = join('', @{$exp{$tbi_id}{$temp_type}});
        push @base_value, $temp;
    }
    push @exp_overview, join (':', @base_value);
}

foreach my $id (@sample_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $min = num (join ('', @{$exp{$tbi_id}{'Min'}}));
    my $first_qu = num (join ('', @{$exp{$tbi_id}{'1st_Qu'}}));
    my $median = num (join ('', @{$exp{$tbi_id}{'Median'}}));
    my $mean = num (join ('', @{$exp{$tbi_id}{'Mean'}}));
    my $third_qu = num (join ('', @{$exp{$tbi_id}{'3rd_Qu'}}));
    my $max = num (join ('', @{$exp{$tbi_id}{'Max'}}));
    push my (@base_value), $delivery_id, $min, $first_qu, $median, $mean, $third_qu, $max;
    push @exp_value, join (':', @base_value);
}


foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $temp_id = join('',@{$exp{$tbi_id}{Delivery_ID}});
    push @delivery_exp_list, $temp_id;
}
#############################################################
#make Mapping Tab (mapping.html) 
#############################################################
my @mapping_sidebar = ("#Alignment_Statistics:Alginment Statistics", "#Cell Overview:Cell Overview", "#Detected Genes Per Cell:Detected Genes Per Cell", "#Expression Sum Per Cell:Expression Sum Per Cell");
my @align_header_list = ("No.","Delivery ID","Number<br>of Reads","Reads Mapped<br>Confidently<br>to Exonic Regions", "Reads Mapped<br>Confidently<br>to Transcriptome","Reads Mapped<br>Confidently<br>to Intronic Regions","Reads Mapped<br>Confidently<br>to Intergenic Regions");
my @cell_header_list = ("No.", "Delivery ID", "Estimated Number<br>of Cells", "Fraction Reads<br>in Cells", "Mean Reads<br>per Cell", "Median Genes<br>per Cell", "Total Genes<br>Detected", "Median UMI Counts<br>per Cell");
my @box_header_list = ("No.", "Delivery ID", "Min", "1st Quart", "Median", "Mean", "3rd Quart", "Max");

my $mapping_dir = "$scRNA_report/mapping";
make_dir($mapping_dir);
my $html_mapping = "$mapping_dir/mapping_index.html";
open my $fh_mapping, '>', $html_mapping or die;

print $fh_mapping TEMPL_HTML_HEAD("..");
print $fh_mapping TEMPL_HEADER($html_mapping);
print $fh_mapping TEMPL_MENU("..");
templ_sidebar($fh_mapping, @mapping_sidebar);
graphics_clumn_hist ($fh_mapping, 'Mapping_Summary_for_Profuced_Sequenicng_Data', 'Alignment_Statistics', @clumn_overview);
###alignment overview
table_header($fh_mapping, 'Alignment Summary', @align_header_list);
table_body($fh_mapping, @align_value);
###cell overview
graphics_boxplot ($fh_mapping, 'scRNA Cell Overview','scRNA Cell Overview', \@cell_overview, \@delivery_gene_list);
table_header($fh_mapping, 'Cell Overview Summary', @cell_header_list);
table_body($fh_mapping, @cell_value);
###Detected Genes Per Cell
graphics_boxplot ($fh_mapping, 'Detected genes per cell','Detected genes per cell', \@gene_overview, \@delivery_gene_list);
table_header($fh_mapping, 'Detected genes Summary', @box_header_list);
table_body($fh_mapping, @gene_value);
###Expression Sum Per Cell
graphics_boxplot ($fh_mapping, 'Expression Sum per cell', 'Expression Sum per cell',  \@exp_overview, \@delivery_exp_list);
table_header($fh_mapping, 'Expression Sum Summary', @box_header_list);
table_body($fh_mapping, @exp_value);
print $fh_mapping TEMPL_FOOTER_2("..");
print $fh_mapping TEMPL_HTML_FOOTER;
close $fh_mapping;

