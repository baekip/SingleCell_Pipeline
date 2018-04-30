#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(checkDir trim make_dir checkFile read_config cmd_system eagle_cmd_system);
use POSIX;

my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $option, $config_file);
GetOptions (
    'script|S=s' => \$script,
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample_id|S=s' => \$sample,
    'log_path|l=s' => \$sh_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$threads,
    'option|r=s' => \$option,
    'config|c=s' => \$config_file
);


my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

make_dir ($sh_path);
make_dir ($output_path);
$input_path = "$input_path/$sample";

my %info;
read_config ($config_file, \%info);
my $filt_param = $info{filt_param};
### option specific information
my ($gene, $umi, $mito) = split /\,/, $filt_param;
my ($min_gene, $max_gene) = split /\-/, $gene;
my ($min_umi, $max_umi) = split /\-/, $umi;
my ($min_mito, $max_mito) = split /\-/, $mito;
my $templ = "$min_gene\_$max_gene\_$min_umi\_$max_umi\_$min_mito\_$max_mito";

if ($option =~ /filt/){
    $output_path = "$output_path/$templ";
    $sh_path = "$sh_path/$templ";
    make_dir ($sh_path);
    make_dir ($output_path);
   
   ### input option specific information
    if ($min_gene eq "NA") {
#        $min_gene = floor($min/10)*10;
        $min_gene = "-Inf"; 
    }if ($min_umi eq "NA"){
        $min_umi = "-Inf";
    }if ($min_mito eq "NA"){
        $min_mito = "-Inf";
    }

    if ($max_gene eq "NA"){
        $max_gene = "Inf";
    }if ($max_umi eq "NA"){
        $max_umi = "Inf";
    }if ($max_mito eq "NA"){
        $max_mito = "Inf";
    }
    
}elsif ($option =~ /basic/){
    $input_path = "$input_path/$templ";
    $output_path = "$output_path/$templ";
    $sh_path = "$sh_path/$templ";
    make_dir ($sh_path);
    make_dir ($output_path);
}

my $sh_file = sprintf ('%s/%s', $sh_path, "seurat.$option.$sample.sh");
my $cellranger_reference = $info{cellranger_reference};
my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_list = split /\,/, $delivery_tbi_id;
my $script_path = $info{dev_path};
my $Rscript = $info{Rscript};


open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N seurat.$option.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
print $fh_sh "date\n\n";
print $fh_sh "#$option\n";

if ($option eq "QC"){
    my $rscript = "$script_path/script/Seurat_sample.QC.R";
    make_dir("$output_path/QC");
    make_dir("$output_path/Rdata");
    print $fh_sh "$Rscript $rscript \\
    $sample \\
    $input_path \\
    $output_path \n\n";  

}elsif ($option =~ /filt/){
    make_dir ("$output_path/Rdata");
    make_dir ("$output_path/Filt");
    
    my $rscript = "$script_path/script/Seurat_sample.Filt.R";
    my $gene_file = "$input_path/QC/at.least.one.txt";
    checkFile ($gene_file);
    my $Rdata_input = "$input_path/Rdata/$sample\.QC.Rda";
    checkFile ($Rdata_input);
    
    my ($min, $first, $median, $mean, $third, $max);
    open my $fh_gene, '<:encoding(UTF-8)', $gene_file or die;
    my $header_line = <$fh_gene>;
    chomp($header_line);
    while (my $row = <$fh_gene>){
        chomp $row;
        $row=trim ($row);
        ($min, $first, $median, $mean, $third, $max) = split /\s+/, $row;
    }
    
    print $fh_sh "$Rscript $rscript \\
    $sample \\
    $input_path \\
    $output_path \\
    $min_gene \\
    $max_gene \\
    $min_umi \\
    $max_umi \\
    $min_mito \\
    $max_mito \n\n";

}elsif ($option =~ /basic/){
    my $rscript = "$script_path/script/Seurat_sample.Basic.R";
    
    make_dir ("$output_path/Rdata");
    make_dir ("$output_path/Basic");

    my $Rdata_input = "$input_path/Rdata/$sample\.Scale.Rda";
    checkFile ($Rdata_input);

    print $fh_sh "$Rscript $rscript \\
    $sample \\
    $input_path \\
    $output_path \n\n";
}elsif ($option =~ /merge/){
    my ($qc_input, $filt_input, $basic_input) = split /\,/, $input_path; 
    
    $qc_input = "$qc_input/$sample/QC";
    $filt_input = "$filt_input/$sample/$templ/Filt";
    $basic_input = "$basic_input/$templ/Basic";
    my $qc_out = "$output_path/";
    my $filt_out = "$output_path/$templ/";
    my $basic_out = "$output_path/$templ/";

    make_merge ($fh_sh, $qc_input, $qc_out);
    make_merge ($fh_sh, $filt_input, $filt_out);
    make_merge ($fh_sh, $basic_input, $basic_out);
}
print $fh_sh "date\n";
close $fh_sh;

eagle_cmd_system ($sh_path, $hostname, $sh_file);

sub make_merge {
    my ($fh, $in, $out) = @_;
    checkDir ($in);
    make_dir ($out);
    print $fh "cp -r $in $out \n";
}
