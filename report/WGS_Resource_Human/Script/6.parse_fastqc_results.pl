use warnings;
use strict;

if (@ARGV !=1){
	printUsage();
}

my $in_general_config = $ARGV[0];
my %info;

read_general_config( $in_general_config, \%info );
my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};

my %hash_sample;
#print "[[12],[],[],[82.50]]\n";
print "[[12],[],[],[82,50]]\n";
print "Sample ID\tPair Num\tPer base qual\tGC contents\tDuplication\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	my $r1_images_path = "$project_path/result/02_fastqc_orig/$tbi_id/$tbi_id\_R1_fastqc/Images/";
	my $r2_images_path = "$project_path/result/02_fastqc_orig/$tbi_id/$tbi_id\_R2_fastqc/Images/";

	my $png_per_base_quality_r1 = "$r1_images_path/per_base_quality.png";
	my $png_per_base_sequence_content_r1 = "$r1_images_path/per_base_sequence_content.png";
	my $png_duplication_levels_r1 = "$r1_images_path/duplication_levels.png";

	my $png_per_base_quality_r2 = "$r2_images_path/per_base_quality.png";
	my $png_per_base_sequence_content_r2 = "$r2_images_path/per_base_sequence_content.png";
	my $png_duplication_levels_r2 = "$r2_images_path/duplication_levels.png";
	
	print "$delivery_id\tForward\t<img:$png_per_base_quality_r1>\t<img:$png_per_base_sequence_content_r1>\t<img:$png_duplication_levels_r1>\n";
	print "$delivery_id\tReverse\t<img:$png_per_base_quality_r2>\t<img:$png_per_base_sequence_content_r2>\t<img:$png_duplication_levels_r2>\n";


}

sub RoundXL {
	sprintf("%.$_[1]f", $_[0]);
}

sub RoundToInt {
	int($_[0] + .5 * ($_[0] <=> 0));
}

sub read_pipeline_config{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/ or $row =~ /^\s/){ next; }
	}
	close($fh);	
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

sub checkFile{
	my $file = shift;
	if (!-f $file){
		die "ERROR ! not found <$file>\n";
	}
}

sub printUsage{
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
