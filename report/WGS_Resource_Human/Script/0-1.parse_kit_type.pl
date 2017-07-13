#!/usr/bin/perl

##################################################
##############Kit_Information#####################
##################################################
#truseq_exome
#aligent_oneseq_target
#sureselect_mouse_exon
#sureselect_human_exon_v3
#sureselect_human_exon_v4
#sureselect_human_exon_v4_plus_UTRs
#sureselect_human_exon_v5
#sureselect_human_exon_v5_plus_UTRs
#sureselect_human_exon_v6
#sureselect_human_exon_v6_plus_UTRs
use strict;
use warnings;

if ( @ARGV != 2 ) {
    printUsage();
}

my $sample_config = $ARGV[0];

my %info;
read_sample_config ($sample_config,\%info);

my $kit_type = $info{kit_type};
my $dev_path = $info{dev_path};
my $project_path = $info{project_path};
my $kit_path = "$dev_path/wes/etc/Kit_type";

if ($kit_type eq "truseq_exome"){
    cp_kit("TruSeq.txt");
}elsif ($kit_type eq "agilent_oneseq_target"){
    cp_kit("OneSeq_Target.txt");
}elsif ($kit_type eq "sureselect_mouse_exon"){
    cp_kit("SureSelect_Mouse.txt");
}elsif ($kit_type eq "sureselect_human_exon_v3"){
    cp_kit("SureSelect_v3.txt");
}elsif ($kit_type eq "sureselect_human_exon_v4"){
    cp_kit("SureSelect_v4.txt");
}elsif ($kit_type eq "sureselect_human_exon_v4_plus_UTRs"){
    cp_kit("SureSelect_v4_UTR.txt");
}elsif ($kit_type eq "sureselect_human_exon_v5"){
    cp_kit("SureSelect_v5.txt"); 
}elsif ($kit_type eq "sureselect_human_exon_v5_plus_UTRs"){
    cp_kit("SureSelect_v5_UTR.txt");
}elsif ($kit_type eq "sureselect_human_exon_v6"){
    cp_kit("SureSelect_v6.txt");
}elsif ($kit_type eq "sureselect_human_exon_v6_plus_UTRs"){
    cp_kit("SureSelect_v6_UTR.txt");
}else { 
    print "ERROR! not found your kit type!!\n"; }

#sub cp_kit {
#    my $kit_info = shift;

sub cp_kit {
    my $target_kit = shift;
    print "Kit_type: $target_kit\n";
    my $cmd_copy = "cp $kit_path/$target_kit $project_path/report/resource/2_Workflow/1_e_table_01.txt";
    #checkFile($kit_path/$target_kit);
    system ($cmd_copy);
}

sub checkFile {
    my $file = shift;
    if ( !-d $file){
        print "ERROR: $file not exist !!!\n";
    }
}

sub read_sample_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while ( my $row = <$fh> ){
        chomp $row;
        if ( $row =~ /^#/) { next; }
        if ( length ($row) == 0 ) { next; }
        my ( $key, $value ) = split /\=/, $row;
        $key = trim( $key );
        $value = trim ( $value );
        $hash_ref->{$key} = $value;
    }
    close $fh;
}

sub trim {
    my @result = @_;
    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result : $result[0]; 
}


sub printUsage {
    print "perl $0 <in.sample.config> <in.pipe.config> \n";
    exit;
}

