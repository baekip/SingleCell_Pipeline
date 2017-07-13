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
print "[[12],[],[],[82]]\n";
print "Sample ID\tInsert Size\tGC contents\tReference Coverage\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;


	my $qualimap_path = "$project_path/result/21_qualimap_run/$tbi_id/images_qualimapReport";

	my $png_genome_insert_size_histogram = "$qualimap_path/genome_insert_size_histogram.png";
	my $png_genome_gc_content_per_window = "$qualimap_path/genome_gc_content_per_window.png";
	my $png_genome_coverage_across_reference = "$qualimap_path/genome_coverage_across_reference.png";

	print "$delivery_id\t<img:$png_genome_insert_size_histogram>\t<img:$png_genome_gc_content_per_window>\t<img:$png_genome_coverage_across_reference>\n";


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
