#!/usr/bin/perl

use strict;
use warnings;

if (@ARGV != 2) {
    printUsage();
}

my $in_general_config = $ARGV[0];

my %info;
read_config ($in_general_config, \%info);

my $project_path = $info{project_path};
my $allele_path = "$project_path/result/18_samtools_call";

my $delivery_tbi_id = $info{delivery_tbi_id};
my @delivery_tbi_list = split /\,/, $delivery_tbi_id;
my $rev = @delivery_tbi_list % 2;

if ( @delivery_tbi_list != 1) {
    print "[[12],[],[],[100,0,100]]\n";
    print "Sample ID\tDistribution of Allele Frequency\tSample ID\tDistribution of Allele Frequency\n"; 
    if($rev == 0){
        for(my $i=0; $i<@delivery_tbi_list; $i=$i+2){

            my($delivery_id_1, $tbi_id_1, $type_id_1) = split /\:/, $delivery_tbi_list[$i];
            my($delivery_id_2, $tbi_id_2, $type_id_2) = split /\:/, $delivery_tbi_list[$i+1];

            my $allele_fig_name_1 = "<img:$allele_path/$tbi_id_1/$tbi_id_1.allele.frq.png>";
            my $allele_fig_name_2 = "<img:$allele_path/$tbi_id_2/$tbi_id_2.allele.frq.png>";

            print "$delivery_id_1\t$allele_fig_name_1\t$delivery_id_2\\n($tbi_id_2)\t$allele_fig_name_2\n";
        }
    }elsif ($rev == 1){ 
        for (my $j=0; $j<@delivery_tbi_list-1; $j=$j+2){

            my($delivery_id_1, $tbi_id_1, $type_id_1) = split /\:/, $delivery_tbi_list[$j];
            my($delivery_id_2, $tbi_id_2, $type_id_2) = split /\:/, $delivery_tbi_list[$j+1];

            my $allele_fig_name_1 = "<img:$allele_path/$tbi_id_1/$tbi_id_1.allele.frq.png>";
            my $allele_fig_name_2 = "<img:$allele_path/$tbi_id_2/$tbi_id_2.allele.frq.png>";

            print "$delivery_id_1\t$allele_fig_name_1\t$delivery_id_2\\n($tbi_id_2)\t$allele_fig_name_2\n";
        }
        my($delivery_id, $tbi_id, $type_id) = split /\:/, $delivery_tbi_list[-1];
        my $allele_fig_name = "<img:$allele_path/$tbi_id/$tbi_id.allele.frq.png>";
        print "$delivery_id\t$allele_fig_name\n";
    }      
}elsif ( @delivery_tbi_list == 1){
    print "[[12],[],[],[150]]\n";
    print "Sample ID\tDistribution of Allele Frequency\n";
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $delivery_tbi_list[0];
    my $allele_fig_name = "<img:$allele_path/$tbi_id/$tbi_id.allele.frq.png>";
    print "$delivery_id\t$allele_fig_name\n";
}

=pod
foreach (@delivery_tbi_list){
    my ($delivery_id, $tbi_id, $type_id) = split /\:/, $_;
        
    my $allele_fig_name = "<img:$allele_path/$tbi_id/$tbi_id.allele.frq.png>";

#    my $vcf_file_name = "$allele_path/$tbi_id/$tbi_id.vcf";
#    my $wc_length = `wc -l $vcf_file_name`;
#    my ($number_variant,$file_name) = split/\s/, $wc_length;
#    my $cnumber_variant = num($number_variant);
    print "$delivery_id\\n($tbi_id)\t$allele_fig_name\n";

}
#print @delivery_tbi_list."\n";
=cut
sub num {
    my $cnum = shift;
    chomp $cnum;
    if ($cnum =~ /\d\./){
        return $cnum;
    }
    while ( $cnum =~ s/(\d+)(\d{3})\b/$1,$2/ ) {
        1;
    }
    my $result = sprintf "%s", $cnum;
    return $result;
}






sub read_config {
    my ($file, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die;
    while (my $row = <$fh>) {
        chomp $row;
        if ($row =~ /^#/) {next;}
        if (length $row == 0 ) {next;}
        my ($key, $value) = split /\=/, $row;
        $key = trim($key);
        $value = trim($value);
        $hash_ref->{$key}=$value;
    }
    close $fh;
}

sub trim {
    my @result =  @_;

    foreach (@result) {
        s/^\s+//;
        s/\s+$//;
    }
    
    return wantarray ? @result:$result[0];
}


sub printUsage {
    print "perl $0 <in.sample.config> <in.pipeline.config> \n";
}
