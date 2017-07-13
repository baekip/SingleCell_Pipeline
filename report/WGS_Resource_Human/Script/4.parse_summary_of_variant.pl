use warnings;
use strict;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);

my $script_snpeff_html_parser = "$script_path/4.snpeff_html_parser.pl";
checkFile( $script_snpeff_html_parser );

if (@ARGV !=1){
	printUsage();
}

my $in_general_config = $ARGV[0];
my %info;
read_general_config( $in_general_config, \%info );

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};
my $project_path = $info{project_path};

my %hash_sample;
print "[[8.5,8.5]]\n";
print "Sample ID\tDOWNSTREAM\tEXON\tINTERGENIC\tINTRON\tSPLICE_SITE_ACCEPTOR\tSPLICE_SITE_DONOR\tSPLICE_SITE_REGION\tTRANSCRIPT\tUPSTREAM\tUTR_3_PRIME\tUTR_5_PRIME\tTotal\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	my $snpeff_html = "$project_path/result/11_snpeff_run/$tbi_id/$tbi_id.snpeff.html";
	checkFile ( $snpeff_html );

	my $result_line = `perl $script_snpeff_html_parser $snpeff_html`;
	chomp($result_line);

	print "$delivery_id\t$result_line\n";
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

sub num{
        my $cnum = shift;
        if ($cnum =~ /\d\./){
                return $cnum;
        }
        while( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/ ) {
                1;
        }
        my $result = sprintf "%s", $cnum;
        return $result;
}


sub printUsage{
	print "Usage: perl $0 <in.config> <in.pipeline.config>\n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_pipeline_config.human.txt\n";
	exit;
}
