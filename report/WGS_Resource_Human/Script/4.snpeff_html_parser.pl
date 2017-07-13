#!/usr/bin/perl -w

use strict;

use Data::Dumper;

if (@ARGV != 1){
	printUsage();
}
my $file_pattern = $ARGV[0];

my @files = glob($file_pattern);

my %hash;
foreach my $html_file (@files){
	read_snpeff_html($html_file,\%hash);
}

my %hash_sum;
foreach my $content (keys %hash){
	my $arr_ref = $hash{$content};
	my @arr = @$arr_ref;
	if ($content ne 'target_chr' and $content ne 'genome_total_len'){
		my $sum_value = sum_(@arr);
                #for (my $i=0; $i<@arr; $i++){
                #	my $val = $arr[$i];
                #	my $chrName= @{$hash{target_chr}}[$i];
                #	print "$content\t$chrName\t$val\n";
                #}
                #print "$content\t$sum_value\n";
		$hash_sum{$content} = $sum_value;
	}elsif ($content eq 'genome_total_len'){
		$hash_sum{$content} = $arr[0];
	}
}

my $num_line = $hash_sum{num_line};
my $num_variants = $hash_sum{num_variant};
my $genome_total_len = num($hash_sum{genome_total_len});
my $genome_eff_len = num($hash_sum{genome_effect_len});

my $snp = $hash_sum{SNP};
my $ins = $hash_sum{INS};
my $del = $hash_sum{DEL};

my $high = $hash_sum{HIGH};
my $low = $hash_sum{LOW};
my $moderate = $hash_sum{MODERATE};
my $modifier = $hash_sum{MODIFIER};

my $missense = $hash_sum{MISSENSE};
my $nonsense = $hash_sum{NONSENSE};
my $silent = $hash_sum{SILENT};

my $DOWNSTREAM = $hash_sum{DOWNSTREAM};
my $EXON = $hash_sum{EXON};
my $INTERGENIC = $hash_sum{INTERGENIC};
my $INTRON = $hash_sum{INTRON};
my $SPLICE_SITE_ACCEPTOR = $hash_sum{SPLICE_SITE_ACCEPTOR};
my $SPLICE_SITE_DONOR = $hash_sum{SPLICE_SITE_DONOR};
my $SPLICE_SITE_REGION = $hash_sum{SPLICE_SITE_REGION};
my $TRANSCRIPT = $hash_sum{TRANSCRIPT};
my $UPSTREAM = $hash_sum{UPSTREAM};
my $UTR_3_PRIME = $hash_sum{UTR_3_PRIME};
my $UTR_5_PRIME = $hash_sum{UTR_5_PRIME};


#$total = num($total);
#$DOWNSTREAM = num($DOWNSTREAM);$EXON = num($EXON);$INTERGENIC = num($INTERGENIC);$INTRON = num($INTRON);$SPLICE_SITE_ACCEPTOR = num($SPLICE_SITE_ACCEPTOR);$SPLICE_SITE_DONOR = num($SPLICE_SITE_DONOR);$SPLICE_SITE_REGION = num($SPLICE_SITE_REGION);$TRANSCRIPT = num($TRANSCRIPT);$UPSTREAM = num($UPSTREAM);$UTR_3_PRIME = num($UTR_3_PRIME);$UTR_5_PRIME = num($UTR_5_PRIME);

$DOWNSTREAM = check_null($DOWNSTREAM);$EXON = check_null($EXON);$INTERGENIC = check_null($INTERGENIC);$INTRON = check_null($INTRON);$SPLICE_SITE_ACCEPTOR = check_null($SPLICE_SITE_ACCEPTOR);$SPLICE_SITE_DONOR = check_null($SPLICE_SITE_DONOR);$SPLICE_SITE_REGION = check_null($SPLICE_SITE_REGION);$TRANSCRIPT = check_null($TRANSCRIPT);$UPSTREAM = check_null($UPSTREAM);$UTR_3_PRIME = check_null($UTR_3_PRIME);$UTR_5_PRIME = check_null($UTR_5_PRIME);
my $total = $DOWNSTREAM + $EXON + $INTERGENIC + $INTRON + $SPLICE_SITE_ACCEPTOR + $SPLICE_SITE_DONOR + $SPLICE_SITE_REGION + $TRANSCRIPT + $UPSTREAM + $UTR_3_PRIME + $UTR_5_PRIME;
$total = check_null($total);

$DOWNSTREAM = num($DOWNSTREAM);$EXON = num($EXON);$INTERGENIC = num($INTERGENIC);$INTRON = num($INTRON);$SPLICE_SITE_ACCEPTOR = num($SPLICE_SITE_ACCEPTOR);$SPLICE_SITE_DONOR = num($SPLICE_SITE_DONOR);$SPLICE_SITE_REGION = num($SPLICE_SITE_REGION);$TRANSCRIPT = num($TRANSCRIPT);$UPSTREAM = num($UPSTREAM);$UTR_3_PRIME = num($UTR_3_PRIME);$UTR_5_PRIME = num($UTR_5_PRIME);
$total = num($total);


print "$DOWNSTREAM\t$EXON\t$INTERGENIC\t$INTRON\t$SPLICE_SITE_ACCEPTOR\t$SPLICE_SITE_DONOR\t$SPLICE_SITE_REGION\t$TRANSCRIPT\t$UPSTREAM\t$UTR_3_PRIME\t$UTR_5_PRIME\t$total\n";

#print "#Number of lines (all vcf files)\t$num_line\n";
#print "#Number of variants\t$num_variants\n";
#print "#Genome total length\t$genome_total_len\n";
#print "#Genome effective length\t$genome_eff_len\n\n";
#
#print "#Number variantss by type\n";
#print "snp\t$snp\n";
#print "ins\t$ins\n";
#print "del\t$del\n\n";
#
#print "#Number of effects by impact\n";
#print "high\t$high\n";
#print "low\t$low\n";
#print "moderate\t$moderate\n";
#print "modifier\t$modifier\n\n";
#
#print "#Number of effects by functional class\n";
#print "missense\t$missense\n";
#print "nonsense\t$nonsense\n";
#print "silent\t$silent\n";

sub check_null {
    my $check_value = shift;
    if (!$check_value){
        return 0;
    }else{
        return $check_value;
    }
}

sub read_snpeff_html{
	my ($file, $hash_ref) = @_;
	open my $fh, '<:encoding(UTF-8)', $file or die;
	my @line_contents;
	while (my $row = <$fh>) {
		chomp $row;
		push @line_contents, $row;
	}
	close($fh);

	parse_snpeff_html(\@line_contents,$hash_ref);
}

sub parse_snpeff_html{
	my ($lines_ref,$hash_ref) = @_;
	my @lines = @{$lines_ref};

	my %hash_one_chr;
	for (my $i=0; $i<@lines; $i++){
		my $line = $lines[$i];
		my ($key,$value);
		#print $line."\n";
		if ($line =~ /Number of lines/){
			$key = "num_line";
			$value = rm_tag($lines[$i+1]);
		}elsif ($line =~ /Number of variants \(before filter\)/){
			$key = "num_variant";
			$value = rm_tag($lines[$i+1]);
		}elsif ($line =~ /Genome total length/){
			$key = "genome_total_len";
			$value = rm_tag($lines[$i+1]);
		}elsif ($line =~ /Genome effective length/){
			$key = "genome_effect_len";
			$value = rm_tag($lines[$i+1]);
		}elsif ($line =~ /Variants rate details/){
			$key = "target_chr";
			$value = rm_tag($lines[$i+5]);
		}elsif ($line =~ /<td> <b> [a-zA-Z\_0-9]+ <\/b> <\/td>/){
			#print $line."\n";
			my $next_line = $lines[$i+1];
			if ($next_line =~ /<th>/){
				$key = rm_tag($line);
				$value = rm_tag($lines[$i+2]);
			}else{ # SNP, MNP, INS, DEL, MIXED, INTERVAL
				$key = rm_tag($line);
				$value = rm_tag($next_line);
			}
		}
		if ($key and $value){
			$hash_one_chr{$key} = $value;
			push @{$hash_ref->{$key}}, $value;
			#print "$key\t$value\n";
		}
	}

}

sub rm_tag{
	my $text = shift;
	if ($text =~ /td class/){
		$text =~ s/<td class\=\"numeric\" bgcolor\=\"\#?[0-9a-zA-Z]+\">//g;
		$text =~ s/<\/?td>//g;
	}elsif ($text =~ /\<\/?[a-zA-z]*\>/){
		$text =~ s/\<\/?[a-zA-Z]*\>//g;
	}

	$text =~ s/^\s+//;
	$text =~ s/\s+$//;

	if ($text =~ /\,/){
		$text =~ s/\,//g;
	}
	return $text;

}

sub sum_ {
  my $result = 0.0;

  for (my $i = 0; $i <= $#_; $i++) {
    $result += $_[$i];
  }

  return $result;
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
	print "Usage: perl $0 <\"in*.snpeff.html\">\n";
	exit;
}
