#!/usr/bin/perl
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
my $alignment_statistics_xls = "$project_path/report/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );


my %hash_sample;
print "[[12],[],[],[100]]\n";

print "Sample ID\tMapped\\nRead\t".
	"Mapped\\nBase\t".
	"Mean Insert Size\\n(std)\t".
        "Mean Coverage\\n(std)\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

        my $mapped_read = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 3 | head -n 1 `;
        chomp $mapped_read;
#        $mapped_read = num($mapped_read);
        
        my $mapped_base = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 4 | head -n 1 `;
        chomp $mapped_base;
    
        my $mean_insert_size = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 5 | head -n 1 `;
        chomp $mean_insert_size;

        my $std_insert_size = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 6 | head -n 1 `;
        chomp $std_insert_size;

        my $mean_coverage = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 7 | head -n 1 `;
        chomp $mean_coverage;


        my $std_coverage = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 8 | head -n 1 `;
        chomp $std_coverage;
 
	print "$delivery_id\t$mapped_read\t$mapped_base\t$mean_insert_size\\n($std_insert_size)\t$mean_coverage\\n($std_coverage)\n";
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
	print "Usage: perl $0 <in.config> \n"; 
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt \n"; 
	exit;
}
