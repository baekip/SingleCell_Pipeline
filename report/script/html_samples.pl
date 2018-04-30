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
use Report_Utils qw(templ_files templ_sidebar table_header table_body table_fastqc);
use Report_Graphics qw(graphics_stack_hist graphics_clumn_hist graphics_boxplot);
use Utils qw(checkDir read_config trim checkFile make_dir RoundXL num); 

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
my $mapping_stat = "$scRNA_report/overview/total.mapping.xls";
checkFile($mapping_stat);

#############################################################
#make Overview Tab (overview.html) 
#############################################################
=pod
use Data::Dumper;
my $overview_dir = "$scRNA_report/overview";
make_dir ($overview_dir);

my %map;
open my $fh_map, '<:encoding(UTF-8)', $mapping_stat or die;
my $header_map = <$fh_map>;
chomp ($header_map);
my @headers_map = split ('\t', $header_map);

while (my $row = <$fh_map>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[1];
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

my $gene_stat = "$report_path/total.at.least.one.txt";
checkFile($gene_stat);

my %gene;
open my $fh_gene, '<:encoding(UTF-8)', $gene_stat or die;
my $header_gene = <$fh_gene>;
chomp ($header_gene);
my @headers_gene = split ('\t', $header_gene);

while (my $row = <$fh_gene>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[1];
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

my $exp_stat = "$report_path/total.expression.sum.per.cell.txt";
checkFile($exp_stat);

my %exp;
open my $fh_exp, '<:encoding(UTF-8)', $exp_stat or die;
my $header_exp = <$fh_exp>;
chomp ($header_exp);
my @headers_exp = split ('\t', $header_exp);

while (my $row = <$fh_exp>){
    chomp $row;
    my @row_list = split /\t/, $row;
    my $sample_id = $row_list[1];
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
print $fh_overview TEMPL_HEADER;
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
=cut
#############################################################
#make Sample Tab (sample.html) 
#############################################################
my $sample_dir = "$scRNA_report/samples";
make_dir($sample_dir);

my $seq_stat = "$rawdata_path/Sequencing_Statistics_Result.xls";
checkFile($seq_stat);
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
my @seq_value;
my @samples_sidebar;
push ((my @stack_samples), "Delivery ID:Index(Gb):R1(Gb):R2(Gb)");
foreach my $id (@sample_list) {
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    push my (@base_value), $delivery_id;
    push @samples_sidebar, "$delivery_id\_QC.html:$delivery_id";
    foreach (@sub_seq) {
        my $tmp_id = "$tbi_id\_$_";
        my $del_id = join('', @{$seq{$tmp_id}{'Delivery_ID'}});
        my $sub_seq = join('', @{$seq{$tmp_id}{'Sub_Seq'}});
        my $total_reads = num (join('', @{$seq{$tmp_id}{'TotalReads'}}));
        my $total_base = num (join('', @{$seq{$tmp_id}{'TotalBases'}}));
        my $total_base_gb = join('', @{$seq{$tmp_id}{'TotalBases(Gb)'}});
        my $gc_rate = join('', @{$seq{$tmp_id}{GC_Rate}});
        my $q30_rate = join('', @{$seq{$tmp_id}{'Q30_MoreBasesRate'}});
        my $q20_rate = join('', @{$seq{$tmp_id}{'Q20_MoreBasesRate'}});

        push my (@base_seq_value), $del_id, $sub_seq, $total_reads, $total_base, $total_base_gb, $gc_rate, $q30_rate, $q20_rate;
        
        $total_base_gb =~ s/\s+Gb//g;
        push @base_value, $total_base_gb;
        push @seq_value, join (':', @base_seq_value);
    }
    push @stack_samples, join (':', @base_value);
}

my @seq_header_list = ("No.","Delivery ID<br>(TBI ID)","Read<br>Information","Total<br>Reads","Total<br>Yield","Total<br>Yield(Gbp)","GC rate (%)","Q30<br>MoreBases<br>Rate","Q20<br>MoreBases<br>");

my $html_samples  =  "$sample_dir/samples_index.html";
open my $fh_samples, '>', $html_samples or die;
print $fh_samples TEMPL_HTML_HEAD("..");
print $fh_samples TEMPL_HEADER($html_samples);
print $fh_samples TEMPL_MENU("..");
templ_sidebar($fh_samples, @samples_sidebar);
graphics_stack_hist ($fh_samples, 'Summary_for_Produced_Sequencing_Data', 'Sequencing_Statistics', @stack_samples);
table_header($fh_samples, 'Sequencing Summary', @seq_header_list);
table_body($fh_samples, @seq_value);
print $fh_samples TEMPL_FOOTER_2("..");
print $fh_samples TEMPL_HTML_FOOTER;
close $fh_samples;

###make fastqc sub index html file 
my ($first_path, $second_path, $third_path, $fourth_path) = split /\,/, $input_path;
foreach my $id (@sample_list){
    my (@BSQ, @SQS, @BSC, @SGC, @DS);
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $id;
    my $sub_html = "$sample_dir/$delivery_id\_QC.html";
    my $sub_samples = "$sample_dir/$delivery_id";
    make_dir($sub_samples);

    my $fastqc_path = "$first_path/$tbi_id";
    checkDir($fastqc_path);
    foreach (@sub_seq) {
        my $tmp_id = "$tbi_id\_$_";
        my $sub_fastqc = "$fastqc_path/$tmp_id\_fastqc/Images";
        checkDir($sub_fastqc);
        my $base_sequence_quality = "$sub_fastqc/per_base_quality.png";
        my $sequency_quality_score = "$sub_fastqc/per_sequence_quality.png";
        my $base_sequence_content = "$sub_fastqc/per_base_sequence_content.png";
        my $sequence_gc_content = "$sub_fastqc/per_sequence_gc_content.png";
        my $duplicate_sequence = "$sub_fastqc/duplication_levels.png";
        
        my $copy_base_sequence_quality = "$sub_samples/$delivery_id\_$_\_per_base_quality.png";
        my $copy_sequency_quality_score = "$sub_samples/$delivery_id\_$_\_per_sequence_quality.png";
        my $copy_base_sequence_content = "$sub_samples/$delivery_id\_$_\_per_base_sequence_content.png";
        my $copy_sequence_gc_content = "$sub_samples/$delivery_id\_$_\_per_sequence_gc_content.png";
        my $copy_duplicate_sequence = "$sub_samples/$delivery_id\_$_\_duplication_levels.png";
        
        copy_file ($base_sequence_quality, $copy_base_sequence_quality); 
        copy_file ($sequency_quality_score, $copy_sequency_quality_score);
        copy_file ($base_sequence_content, $copy_base_sequence_content);
        copy_file ($sequence_gc_content, $copy_sequence_gc_content);
        copy_file ($duplicate_sequence, $copy_duplicate_sequence);

        push @BSQ, "$delivery_id/$delivery_id\_$_\_per_base_quality.png";
        push @SQS, "$delivery_id/$delivery_id\_$_\_per_sequence_quality.png";
        push @BSC, "$delivery_id/$delivery_id\_$_\_per_base_sequence_content.png";
        push @SGC, "$delivery_id/$delivery_id\_$_\_per_sequence_gc_content.png";
        push @DS, "$delivery_id/$delivery_id\_$_\_duplication_levels.png";
    }
    
    open my $fh_sub, '>', $sub_html or die;
    print $fh_sub TEMPL_HTML_HEAD("..");
    print $fh_sub TEMPL_HEADER($sub_html);
    print $fh_sub TEMPL_MENU("..");
    templ_sidebar ($fh_sub, @samples_sidebar);
    table_fastqc ($fh_sub, 'Base Sequence Quality', @BSQ); 
    table_fastqc ($fh_sub, 'Sequence Qulaity Scores', @SQS); 
    table_fastqc ($fh_sub, 'Base Sequence Content', @BSC); 
    table_fastqc ($fh_sub, 'Sequence GC Content', @SGC); 
    table_fastqc ($fh_sub, 'Duplicate Sequence', @DS); 
    print $fh_sub TEMPL_FOOTER_2("..");
    print $fh_sub TEMPL_HTML_FOOTER;
    close $fh_sub;
}

sub copy_file {
    my ($file, $copy_file) = @_;
    checkFile ($file);
    my $cmd = "cp $file $copy_file";
    system ($cmd);
}

