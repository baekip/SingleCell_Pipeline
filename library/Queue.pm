#############################################################
#Author: baekip
#Date: 2017.2.27
#############################################################
package Queue;
use File::Basename;
use Cwd 'abs_path';
use lib dirname (abs_path $0) . '/../library';
use Utils qw (checkFile make_dir);
use Exporter qw(import);
our @EXPORT_OK = qw(CheckQsub pipe_arrange program_run);
#############################################################
##sub
##############################################################
sub CheckQsub{
    my @job_list = @_;
    my $stop = 1;
    
    while($stop){
    my $command = "qstat";
    my $status=qx[$command];
    my @jobsStatus=split(/\n/,$status);
    
    my $job_str = join ('|', @job_list);
#    my $job_str = join ('|', map quotemeta @job_list);
#    print "job_str: $job_str\n";
    my @targetJobStatus = grep ( /$job_str/, @jobsStatus); #Here we get only the status of the of interest 
    if(scalar(@targetJobStatus )== 0) #if no job is running
    {$stop=0;
        }
        sleep(5);
    }
}

sub pipe_arrange { 
    my ($pipe, $hash_ref) = @_;
    open my $fh, '<:encoding(UTF-8)', $pipe or die;
    $hash_ref->{'00'}="rawdata";
    while (my $row = <$fh>) {
        chomp $row; 
        if ($row =~ /^#|^\s+/){next;}
        if (length ($row) == 0){next;}
        my ($order, $input_order, $program, $option, $type, $threads) = split /\s+/, $row;
        if ($option =~ /,/){
            my @option_list = split /\,/, $option;
            $option = $option_list[0];
        }else {}

        my $run_name = sprintf ("%s_%s_%s", $order, $program, $option);
        $hash_ref->{$order}=$run_name;
    }
}
sub program_run {
    my $datestring=localtime();
    print "-------------------------------------------------------\n";
    print "Start: $datestring\n";
    print "-------------------------------------------------------\n";
    
    my ($script, $program, $input_path, $sample, $sh_path, $output_path, $threads, $config) = @_;
#    $input_path = sprintf ("%s/%s", $input_path, $sample);
    $sh_path = sprintf ("%s/%s/", $sh_path, $sample);
    $output_path = sprintf ("%s/%s/", $output_path, $sample);
    checkFile($script);
    make_dir($output_path);
    
    my $cmd = "perl $script -p $program -i $input_path -S $sample -l $sh_path -o $output_path -t $threads -c $config";
    print $cmd."\n";
    return $cmd;
}
1;
