#!/usr/bin/perl

##################################################
##############Kit_Information#####################
##################################################
#truseq_exome
#aligent_oneseq_target
#sureselect_exon_focus
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
my $read_length = $info{read_length};
my $kit_path = "$dev_path/wes/etc/Kit_type";
my $kit_sh_path = "$dev_path/wes/etc/Kit_type_sh";

if ($kit_type eq "truseq_exome"){
    cp_kit_sh("TruSeq.sh");
}elsif ($kit_type eq "agilent_oneseq_target"){
    cp_kit_sh("OneSeq_Target.sh");
}elsif ($kit_type eq "sureselect_mouse_exon"){
    cp_kit_sh("SureSelect_Mouse.sh");
}elsif ($kit_type eq "sureselect_human_focuse"){
    cp_kit_sh("SureSelect_focus.sh");
}elsif ($kit_type eq "sureselect_human_exon_v3"){
    cp_kit_sh("SureSelect_v3.sh");
}elsif ($kit_type eq "sureselect_human_exon_v4"){
    cp_kit_sh("SureSelect_v4.sh");
}elsif ($kit_type eq "sureselect_human_exon_v4_plus_UTRs"){
    cp_kit_sh("SureSelect_v4_UTR.sh");
}elsif ($kit_type eq "sureselect_human_exon_v5"){
    cp_kit_sh("SureSelect_v5.sh"); 
}elsif ($kit_type eq "sureselect_human_exon_v5_plus_UTRs"){
    cp_kit_sh("SureSelect_v5_UTR.sh");
}elsif ($kit_type eq "sureselect_human_exon_v6"){
    cp_kit_sh("SureSelect_v6.sh");
}elsif ($kit_type eq "sureselect_human_exon_v6_plus_UTRs"){
    cp_kit_sh("SureSelect_v6_UTR.sh");
}else { 
    print "ERROR! not found your kit type!!\n"; 
}

#sub cp_kit {
#    my $kit_info = shift;

sub cp_kit_sh {
    my $target_kit = shift;
    print "Kit_type: $target_kit\n";
    my $cmd_sh = "bash $kit_sh_path/$target_kit $read_length $project_path/report/resource/2_Workflow/1_e_table_01.txt";
    #checkFile($kit_path/$target_kit);
    system ($cmd_sh);
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

