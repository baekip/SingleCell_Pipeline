#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my $in_pipeline_config = $ARGV[1];

my %info;
read_sample_config($in_sample_config, \%info);

my $project_path = $info{project_path};
my $alignment_xls = "$project_path/report/alignment.statistics.xls";
#print `cat $alignment_xls`;

my $sample_list = $info{delivery_tbi_id};
my @sample_tbi_list = split /\,/, $sample_list;

print "[[11],[],[],[110]]\n";
print "Sample ID\tSequence\\nRead\tDe-Duplicated\\nRead\tMapping\\nRead\tUnique\\nRead\tOn-Target\\nRead\n";

foreach (@sample_tbi_list){
    my ($delivery_id, $tbi_id, $type) = split /\:/, $_;
=pod 
    my $sequence_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 2 | head -n 1`;
    chomp $sequence_read;
    $sequence_read = num($sequence_read);
    
    my $deduplicated_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 3 | head -n 1`;
    chomp $deduplicated_read;
    $deduplicated_read = num($deduplicated_read);

    my $mapping_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 5 | head -n 1`;
    chomp $mapping_read;
    $mapping_read = num($mapping_read);

    my $unique_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 9 | head -n 1`;
    chomp $unique_read;
    $unique_read = num($unique_read);

    my $on_target_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 11 | head -n 1`;
    chomp $on_target_read;
    $on_target_read = num($on_target_read);
=cut
    my $sequence_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 2 | head -n 1`;
    chomp $sequence_read;
    $sequence_read = num($sequence_read);
    
    my $deduplicated_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 8 | head -n 1`;
    chomp $deduplicated_read;
    $deduplicated_read = num($deduplicated_read);

    my $mapping_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 10 | head -n 1`;
    chomp $mapping_read;
    $mapping_read = num($mapping_read);

    my $unique_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 14 | head -n 1`;
    chomp $unique_read;
    $unique_read = num($unique_read);

    my $on_target_read = `cat $alignment_xls | grep \"^$tbi_id\" | cut -f 16 | head -n 1`;
    chomp $on_target_read;
    $on_target_read = num($on_target_read);


    print "$delivery_id\t$sequence_read\t$deduplicated_read\t$mapping_read\t$unique_read\t$on_target_read\n";}

sub num {
    my $cnum = shift;
    if ($cnum =~ /\d\./){
        return $cnum;
    }
    while ( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/){
        1;
    }
    my $result = sprintf "%s", $cnum;
    return $result;
}

sub read_sample_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/){next;}
        if (length $row == 0) {next;}

        my ($key, $value) = split /\=/, $row;
        $key = trim ($key);
        $value = trim ($value);
        $hash_ref->{$key} = $value;
    }
}

sub trim { 
    my @result = @_;

    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
        # print @result;
        # print "\n";
    }

    return wantarray ? @result : $result[0];
}

sub printUsage {
    print "Usage: perl $0 <in.sample.config> <in.pipeline.config> \n";
}
