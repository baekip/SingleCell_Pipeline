#!/usr/bin/perl 

use strict;
use warnings;

use File::Basename;
use Cwd qw(abs_path);
my $script_path = dirname (abs_path $0);

if (@ARGV != 1) {
    printUsage();
}

my $in_sample_config = $ARGV[0];
my %hash;
read_sample_config ($in_sample_config, \%hash);

my @list_sample_id = split /\,/, $hash{delivery_tbi_id};

my $project_path = $hash{project_path};
my $alignment_statistics_xls = "$project_path/report/alignment.statistics.xls";
checkFile ( $alignment_statistics_xls );

print "[[11],[],[],[100]]\n";
print "Sample ID\tTS\tTV\tTs/Tv\n";
#print "Sample ID\tTS\tTV\tTs/Tv\tHetero\\nVariants\tHomo\\nVariants\tHetero\\n/Homo\n";

foreach (@list_sample_id) {
    my ($delivery_id,$tbi_id,$type_id) = split /\:/, $_;
    my $html = "$project_path/result/11_snpeff_run/".$tbi_id."/".$tbi_id.".snpeff.html";

#print $html."\n";
    open my $fh_html, '<:encoding(UTF-8)', $html or die;
    my @html_arr;
    while ( my $row = <$fh_html>){
        chomp $row;
        push @html_arr, $row;
    } close $fh_html;
#    print @html_arr;

    my @Ts;
    my @Tv;
    my @ratio;
        for (my $i=0; $i<@html_arr; $i++){
            if ( $html_arr[$i] =~ /Transitions/){
                push @Ts ,$html_arr[$i];
            }elsif ( $html_arr[$i] =~ /Transversions/){
                push @Tv ,$html_arr[$i];
            }elsif ( $html_arr[$i] =~ /Ts\/Tv/){
                push @ratio , $html_arr[$i];
            }
        } 
        
        my ($Ts_type, $transition, $transition_1) = split /\,/, $Ts[1];
        my ($Tv_type, $transversion, $transversion_1) = split /\,/,$Tv[1];
        my $ratio = $transition / $transversion;
        $ratio = &RoundXL ($ratio, 3);

        my $ts = num($transition);
        my $tv = num($transversion);
       
        my $hetero = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 30 | head -n 1 `;
        chomp $hetero;
        $hetero = num($hetero);

        my $homo = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 31 | head -n 1 `;
        chomp $homo;
        $homo = num($homo);
        
        my $hh_ratio = `cat $alignment_statistics_xls | grep \"^$tbi_id\" | cut -f 32 | head -n 1 `;
        chomp $hh_ratio;
        $hh_ratio = num($hh_ratio);
        
        print "$delivery_id\t$ts\t$tv\t$ratio\n";
#        print "$delivery_id\t$ts\t$tv\t$ratio\t$hetero\t$homo\t$hh_ratio\n";
}

sub RoundXL {
    sprintf ("%.$_[1]f", $_[0]);
}

sub checkFile {
    my $file = shift;
    if ( !-f $file) {
        die "ERROR! not found <$file>\n";
    }
}


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
    while ( my $row = <$fh>){
        chomp $row;
        if ($row =~ /^#/) { next; }
        if (length $row == 0) { next; }

        my($key, $value) = split /\=/, $row;
         $key = trim ($key);
         $value = trim ($value);
         $hash_ref->{$key} = $value;
    }
    close $fh;
}



sub trim {
    my @result = @_;
    
    foreach (@result){

        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @result : $result[0];
}

sub printUsage {
    print "perl $0 <in.sample.config> <in.pipeline.config> \n";
}
