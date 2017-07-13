#!/usr/bin/perl
use warnings;
use strict;

if (@ARGV != 2){
    printUsage();
}

my $read_length = $ARGV[0];
my $kit_table = $ARGV[1];
print $kit_table."\n";
print "Reference name: ";
my $reference = <STDIN>;
chomp $reference;

print "Library Prep Kit: ";
my $kit = <STDIN>;
chomp $kit;

print "Read Length $read_length \n";

#------
open my $fh, '>', $kit_table or die;
print $fh "[[11],[],[TL],[280]]\n";
print $fh "Reference\t $reference \n";
print $fh "Library Prep Kit \t $kit \n";
print $fh "Read length \t $read_length X 2 \n";
print $fh "Coverage uniformity (10X) \t > 90% \n";
close $fh;

sub printUsage {
    print "perl $0 read_length kit_table \n";
    exit;
}
