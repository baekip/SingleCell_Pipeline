#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Sys::Hostname;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
use lib dirname (abs_path $0) . '/../library';
use Utils qw(make_dir checkFile read_config cmd_system);


my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $option, $config_file);
GetOptions (
    'script|S=s' => \$script,
    'program|p=s' => \$program,
    'input_path|i=s' => \$input_path,
    'sample_id|S=s' => \$sample,
    'log_path|l=s' => \$sh_path,
    'output_path|o=s' => \$output_path,
    'threads|t=s' => \$threads,
    'option|r=s' => \$option,
    'config|c=s' => \$config_file
);


my $hostname=hostname;
#my $queue;
#if ( $host eq 'eagle'){
#    $queue = 'isaac.q';
#}else{
#    $queue = 'all.q';
#}

make_dir ($sh_path);
make_dir ($output_path);

my $sh_file = sprintf ('%s/%s', $sh_path, "delly.$sample.sh");
my %info;
read_config ($config_file, \%info);


my $script_path = dirname (abs_path $0);


#####Requirement
#####Requirement
my $reference = $info{reference};
my $excludeTemplates = $info{excludeTemplates};
my $delivery_tbi_id = $info{delivery_tbi_id};
my $bcftools = $info{bcftools};
my %id_hash;
match_id ($delivery_tbi_id, \%id_hash);

my $delivery_id = $id_hash{$sample};
if (!defined $sample) {
    die "ERROR! Check your config file at <delivery_tbi_id>";
}
my $input_bam = "$input_path/$sample/$sample\.bam";
my $INV_bcf = "$output_path/$delivery_id\.delly_INV.bcf";
my $TRA_bcf = "$output_path/$delivery_id\.delly_TRA.bcf";
my $INV_vcf = "$output_path/$delivery_id\.delly_INV.vcf";
my $TRA_vcf = "$output_path/$delivery_id\.delly_TRA.vcf";
my $INV_filter = "$output_path/$delivery_id\.delly_INV_PASS.vcf";
my $TRA_filter = "$output_path/$delivery_id\.delly_TRA_PASS.vcf";
my $INV_table = "$output_path/$delivery_id\.delly_INV_PASS_Table.txt";
my $TRA_table = "$output_path/$delivery_id\.delly_TRA_PASS_Table.txt";
my $table_make_pl = "$script_path/delly_make_table.pl";
checkFile($table_make_pl);


#######
open my $fh_sh, '>', $sh_file or die;
print $fh_sh "#!/bin/bash\n";
print $fh_sh "#\$ -N delly.$sample\n";
print $fh_sh "#\$ -wd $sh_path \n";
print $fh_sh "#\$ -pe smp $threads\n";
#print $fh_sh "#\$ -q $queue\n";
print $fh_sh "date\n";

printf $fh_sh ("%s call -t INV -g %s -x %s -o %s %s \n", $program, $reference, $excludeTemplates, $INV_bcf, $input_bam);
printf $fh_sh ("%s call -t TRA -g %s -x %s -o %s %s \n", $program, $reference, $excludeTemplates, $TRA_bcf, $input_bam);

printf $fh_sh ("%s view %s > %s \n", $bcftools, $INV_bcf, $INV_vcf);
printf $fh_sh ("%s view %s > %s \n", $bcftools, $TRA_bcf, $TRA_vcf);

printf $fh_sh ("cat %s | grep -v \'##\' | awk \'\{if\(\$7 == \"PASS\"\) print \$0\}\' | grep -v 'IMPRECISE' > %s \n", $INV_vcf, $INV_filter); 
printf $fh_sh ("cat %s | grep -v \'##\' | awk \'\{if\(\$7 == \"PASS\"\) print \$0\}\' | grep -v 'IMPRECISE' > %s \n", $TRA_vcf, $TRA_filter);

printf $fh_sh ("perl %s -c INV -i %s -o %s \n", $table_make_pl, $INV_filter, $INV_table);
printf $fh_sh ("perl %s -c TRA -i %s -o %s \n", $table_make_pl, $TRA_filter, $TRA_table);

print $fh_sh "date\n";
close $fh_sh;

cmd_system ($sh_path, $hostname, $sh_file);

sub match_id {
    my ($id_list, $hash_ref) = @_;
    my @id_array = split /\,/, $id_list;
    foreach my $id (@id_array){
        my ($delivery_id, $tbi_id, $type) = split /\:/, $id;
        $hash_ref->{$tbi_id}=$delivery_id;
    }
}
