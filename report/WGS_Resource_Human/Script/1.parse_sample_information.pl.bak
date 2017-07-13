#!/usr/bin/perl
use warnings;
use strict;

if (@ARGV !=2){
	printUsage();
}

my $in_general_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;

read_general_config( $in_general_config, \%info );
#read_pipeline_config();

my @list_delivery_tbi_id = split /\,/, $info{delivery_tbi_id};

my $project_path = $info{project_path};

#my $rawdata_path = "$project_path/rawdata";
my $rawdata_path = $info{rawdata_path};

# Index, Total yield, Q20/Q30 Bases PF
my $Sequencing_Statistics_Result_xls = "$rawdata_path/Sequencing_Statistics_Result.xls";
checkFile( $Sequencing_Statistics_Result_xls );

my %hash_sample;
print "[[12],[],[],[110]]\n";
print "Sample ID\tTotal reads\tTotal\\nyield(Gbp)\tN rate\tQ30\\nMoreBases\\nRate\tQ20\\nMoreBases\\nRate\n";
foreach ( @list_delivery_tbi_id ){
	my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;

	# Total reads 
	my $total_reads = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 3`;
	chomp($total_reads);
        $total_reads = num($total_reads);

        #my $index = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 2`;
	#chomp($index);

	my $total_yield = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 4`;
	chomp($total_yield);
	$total_yield = changeGbp($total_yield);

        my $N_rate = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 13`;
        chomp($N_rate);
        
        my $q30_base_pf = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 15`;
	chomp($q30_base_pf);

	my $q20_base_pf = `cat $Sequencing_Statistics_Result_xls | grep \"^$tbi_id\" | cut -f 17`;
	chomp($q20_base_pf);
	
	print "$delivery_id\t$total_reads\t$total_yield\t$N_rate\t$q30_base_pf\t$q20_base_pf\n";
}

#cat /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/result/01_fastqc_orig/TN1507D0293/TN1507D0293_1_fastqc/fastqc_data.txt | grep "Total Sequences" | sed 's/Total Sequences\s//g'


sub read_pipeline_config{
	my $file = shift;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	while (my $row = <$fh>) {
		chomp $row;
		if ($row =~ /^#/ or $row =~ /^\s/){ next; }
	}
	close($fh);	
}

sub changeGbp{
	my $val = shift;
	$val = $val / 1000000000;
	$val = &RoundXL ($val, 2);
	return $val;
}

sub RoundXL {
	sprintf("%.$_[1]f", $_[0]);
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
