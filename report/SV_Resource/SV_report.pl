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
use Report qw(report_header report_opt report_int report_info report_workflow );
use Result qw(result_scatter_plot result_diagram_plot result_table INV_result TRA_result SV_header);
use Utils qw(cp_file read_config trim checkFile make_dir); 

my $ver = "0.3.1";
my ($in_config, $input_path, $output_path);
GetOptions(
    'config=s' => \$in_config,
    'output_path=s' => \$output_path,
    'input_path=s' => \$input_path,
);

if (!defined $in_config or !-f $in_config){
    die "ERROR! check your config file with -c option \n";
}
print "read config: $in_config \n";

my %info;
read_config($in_config, \%info);

#############################################################
#Requirement 
#############################################################
my $script_path = dirname(abs_path $0);
my $project_id = $info{project_id};
my $project_path = $info{project_path};
my $delivery_tbi_id = $info{delivery_tbi_id};
my $build = $info{snpeff_db};
my @delivery_list = split /\,/, $delivery_tbi_id;
my ($cnv_result, $sv_result) = split /\,/, $input_path;

#############################################################
#make result folder 
#############################################################
my $report_path = "$output_path/report";
make_dir($report_path);

#############################################################
#make report 
#############################################################

my $cnv_path = "$project_path/result/51_cnvkit_wgs";
my $sv_path = "$project_path/result/52_delly_wgs";

my $report_rmd = "$report_path/$project_id\_SV_AnalysisReport.rmd";
my $report_html = "$report_path/$project_id\_SV_AnalysisReport.html";
open my $fh, '>', $report_rmd or die;

report_header($fh, $ver, $project_id);
report_opt($fh, $report_path);
report_int($fh);
report_info($fh,$build);
report_workflow($fh,"images/workflow.png");
make_dir ("$report_path/images");
checkFile("/$script_path/../images/workflow.png");
cp_file ("/$script_path/../images/workflow.png", "$report_path/images/");

foreach (@delivery_list) {
    my ($id, $tbi_id, $type_id) = split /\:/, $_;
    print $id."\n";

    my $cnv_report_path = "$report_path/result/$id/cnvkit_run";
    make_dir($cnv_report_path);

    my $cns = "$cnv_path/$tbi_id/$id\.cns";
    my $cnr = "$cnv_path/$tbi_id/$id\.cns";
    my $scatter_png = "$cnv_path/$tbi_id/$id\-scatter.png";
    my $diagram_png = "$cnv_path/$tbi_id/$id\-diagram.png";
    my $gainloss_table = "$cnv_path/$tbi_id/$id\.gene.gainloss.txt";

    cp_file ($cns, "$cnv_report_path/$id\.cns");
    cp_file ($cnr, "$cnv_report_path/$id\.cnr");
    cp_file ($scatter_png, "$cnv_report_path/$id\-scatter.png");
    cp_file ($diagram_png, "$cnv_report_path/$id\-diagram.png");
    cp_file ($gainloss_table, "$cnv_report_path/$id\.gene.gainloss");
    result_scatter_plot($fh,"./result/$id/cnvkit_run/$id-scatter.png",$id);
    result_diagram_plot($fh,"./result/$id/cnvkit_run/$id-diagram.png",$id);
    result_table($fh,"./result/$id/cnvkit_run/$id.gene.gainloss",$id);

    my $sv_report_path = "$report_path/result/$id/delly_run/";
    make_dir($sv_report_path);
   #
    my $inv_table = "$sv_path/$tbi_id/$id\.delly_INV_PASS_Table.txt";
    my $tra_table = "$sv_path/$tbi_id/$id\.delly_TRA_PASS_Table.txt";
    my $cp_cmd = "cp $sv_path/$tbi_id/$id*vcf $sv_report_path";
    system ($cp_cmd);
    cp_file ($inv_table, $sv_report_path);
    cp_file ($tra_table, $sv_report_path);
    SV_header ($fh);
    INV_result ($fh, $id, $inv_table);
    TRA_result ($fh, $id, $tra_table);
}
close $fh;

my $render_cmd = "R -e \'library(\"rmarkdown\"); render(\"$report_rmd\")\'";
system($render_cmd);

if (-e $report_html){
    `rm $report_rmd`;
}

