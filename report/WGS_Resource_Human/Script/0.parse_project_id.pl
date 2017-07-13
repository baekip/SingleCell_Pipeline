#!/usr/bin/perl
use warnings;
use strict;

if (@ARGV !=1){
	printUsage();
}

my $in_general_config = $ARGV[0];
my %info;
read_general_config( $in_general_config, \%info );

my $project_id = $info{project_id};

# Index, Total yield, Q20/Q30 Bases PF
my %hash_sample;
print "[[15],[],[R]]\n";
print "$project_id\n";
print "\n\n\n\n\n\n\n\n\n\n";

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
                s/^\s+//g;
                s/\s+$//g;
        }
        return wantarray ? @result : $result[0];
}

sub printUsage{
	print "Usage: perl $0 <in.config> \n";
	print "Example: perl $0 /BiO/BioProjects/FOM-Human-WES-2015-07-TBO150049/wes_config.human.txt \n"; 
	exit;
}
