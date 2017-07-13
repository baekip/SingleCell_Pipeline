#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Long;

my $param_delete;
GetOptions(
        'delete' => \$param_delete,
);

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);
$script_path = $script_path."/Script";

my $general_config_file = $ARGV[0];
my $pipeline_config_file = $ARGV[1];

if (@ARGV !=1){
    printUsage();
}

my %info;
read_general_config ($general_config_file, \%info);

my $version = "V1.0";
my $project_path = $info{project_path};
my $out_path = $info{report_path};
my $project_id = $info{project_id};
my $dev_path = $info{dev_path};
my $Rscript = "Rscript";
my $java = $info{java_1_7}; 
checkFile( $java );
$dev_path="$dev_path/report";
my $text2pdf = "$dev_path/etc/text2pdf.jar"; 
checkFile ( $text2pdf );
my $user_font_file = "$dev_path/etc/Font/SangSangBodyM.ttf";
checkFile ( $user_font_file );
my $user_CI_file = "$dev_path/etc/CI/Theragen_CI.png";
checkFile ($user_CI_file);

my $template_resource_path = "$dev_path/WGS_Resource_Human/PDF_resource"; ###
if (!-d $template_resource_path){
	die "ERROR ! not found template resource directory\n";
}

# make new_path
make_dir ($out_path);

# check before reults
my $output_pdf = "$out_path/Analysis_report_".$project_id.".pdf"; #########


print `rm -r $out_path/temp\n`;
print `rm -r $out_path/resource\n`;
print `rm $output_pdf\n`;

=pod
if (-d "$out_path/temp" or -d "$out_path/resource" or -f $output_pdf){
	die "# Warning! Check your before results for making pdf\n".
	"rm -r $out_path/temp\n".
	"rm -r $out_path/resource\n".
	"rm $output_pdf\n";
}
=cut

# copy template resource directory into out_path;
my $resource_path = "$out_path/resource";
my $cmd_copy_template = "cp -rL $template_resource_path $resource_path";
system( $cmd_copy_template );

my $script_0 = $script_path."/0.parse_project_id.pl";
checkFile( $script_0 );

#my $script_0_1 =$script_path."/0-1.parse_kit_type.pl";
#my $script_0_1 =$script_path."/0-1.parse_kit_type_sh.pl";
#checkFile( $script_0_1 );

my $script_1 = $script_path."/1.parse_sample_information.pl";
checkFile( $script_1 );

my $script_2 = $script_path."/2.parse_summary_of_read_sequence.pl";
checkFile( $script_2 );

my $script_4 = $script_path."/4.parse_summary_of_variant.pl";
checkFile( $script_4 );

my $script_4_plot = $script_path."/4.parse_summary_of_variant.R";
checkFile ( $script_4_plot );

my $script_6 = $script_path."/6.parse_fastqc_results.pl";
checkFile( $script_6 );

my $script_7 = $script_path."/7.parse_qualimap_results.pl";
checkFile( $script_7 );

my $script_10 =$script_path."/10.number_variant_by_type.pl";
checkFile( $script_10 );
my $script_10_plot =$script_path."/10.number_variant_by_type.R";
checkFile( $script_10_plot );

my $script_11 = $script_path."/11.number_of_effect.pl";
checkFile( $script_11 );
my $script_11_plot = $script_path."/11.number_of_effect.R";
checkFile( $script_11_plot);

my $script_13 = $script_path."/13.parse_trans.pl";
checkFile( $script_13);
my $script_13_plot = $script_path."/13.parse_trans.R";
checkFile( $script_13_plot);

run_script ( $script_0, $general_config_file, "$resource_path/0-1_Cover_page/c_intro_title.txt" );
#run_script_1 ($script_0_1, $general_config_file );
run_script ( $script_1, $general_config_file, "$resource_path/1-1_Sample_Information/c_table_01.txt" );
run_script ( $script_2, $general_config_file,  "$resource_path/3-1_Results_Summary/1_c_table_01.txt" );

run_script ( $script_6, $general_config_file, "$resource_path/3-4_Results_QualityControl/1_a_photoMap_01.txt" );
run_script ( $script_7, $general_config_file, "$resource_path/3-4_Results_QualityControl/2_b_photoMap_01.txt" );

#run_script ($script_8, $general_config_file, $pipeline_config_file, "$resource_path/3-5_Results_Sequence/1_c_table_01.txt");
#my $cmd_script_8_plot = "$Rscript $script_8_plot \"$resource_path/3-5_Results_Sequence/1_c_table_01.txt\" \"$resource_path/3-5_Results_Sequence/1_b_photo_01.PNG\"";
#system($cmd_script_8_plot);

#run_script ( $script_9, $general_config_file, $pipeline_config_file, "$resource_path/3-5_Results_Sequence/2_c_table_01.txt" );
#my $cmd_script_9_plot = "$Rscript $script_9_plot \"$resource_path/3-5_Results_Sequence/2_c_table_01.txt\" \"$resource_path/3-5_Results_Sequence/2_b_photo_01.PNG\"";
#system($cmd_script_9_plot);

run_script ($script_10, $general_config_file, "$resource_path/3-2_Annotated_Variants/1_c_table_01.txt" );
my $cmd_script_10_plot = "$Rscript $script_10_plot \"$resource_path/3-2_Annotated_Variants/1_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/1_b_photo_01.PNG\"";
system($cmd_script_10_plot);

run_script ($script_13, $general_config_file, "$resource_path/3-2_Annotated_Variants/2_c_table_01.txt" );
#my $cmd_script_13_plot = "$Rscript $script_13_plot \"$resource_path/3-2_Annotated_Variants/2_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/2_b_photo_01.PNG\"";
#system($cmd_script_13_plot);

run_script ( $script_4, $general_config_file, "$resource_path/3-2_Annotated_Variants/3_c_table_01.txt" );
my $cmd_script_4_plot = "$Rscript $script_4_plot \"$resource_path/3-2_Annotated_Variants/3_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/3_b_photo_01.PNG\"";
system($cmd_script_4_plot);

run_script ($script_11, $general_config_file, "$resource_path/3-2_Annotated_Variants/4_c_table_01.txt" );
my $cmd_script_11_plot = "$Rscript $script_11_plot \"$resource_path/3-2_Annotated_Variants/4_c_table_01.txt\" \"$resource_path/3-2_Annotated_Variants/4_b_photo_01.PNG\"";
system($cmd_script_11_plot);

# sp : start page 
# hl : header line
# fl : floating line
# ht : header title
# ha : header arrange
# fa : floating arrange
# r : resource folder
# of : output pdf filename

chdir $out_path;
my $cmd_make_pdf = "$java -jar $text2pdf -sp 2 -hl -fl -ht Analysis Report $version -ha r -fa r -r $resource_path -of $output_pdf -f $user_font_file -fi $user_CI_file";
print $cmd_make_pdf."\n";
system($cmd_make_pdf);

if ($param_delete){
    system("rm -r $resource_path");
    system("rm -r $out_path/temp");
}

########################################################################
#Sub routine
########################################################################
sub run_script{
	my ( $script, $config_1, $outfile ) =  @_;
	my $command = "perl $script $config_1  > \"$outfile\"";
	print $command."\n";
	system($command);
}

sub make_dir {
    my $dir = shift;
    if (!-d $dir){
        system ("mkdir -p $dir");
    }
}

sub run_script_1{
	my ( $script, $config_1) =  @_;
		
	my $command = "perl $script $config_1 ";
	print $command."\n";
	system($command);
}

sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub read_general_config{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/){ next; } # pass header line
		if (length($row) == 0){ next; }

		my ($key, $value) = split /\=/, $row;
		$key = trim($key);
		$value = trim($value);
		$hash_ref->{$key} = $value;
	}
	close($fh);	
}

sub trim {
	my @result = @_;

	foreach (@result) {
		s/^\s+//;
		s/\s+$//;
	}

	return wantarray ? @result : $result[0];
}

sub printUsage{
	print "Usage: perl $0 <in.config> \n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt \n";
	exit;
}
