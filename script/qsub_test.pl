#!/usr/bin/perl

use strict;
use warnings;

sub CheckQsub{
    my $job_name = shift;
    my $stop = 1;
    
    while($stop){
    
    $command =  "qstat";
    my $status=qx[$command];
    my @jobsStatus=split(/\n/,$status);
    
    my @targetJobStatus  = grep(/$job_name/,@jobsStatus);  #Here we get only the status of the of interest

    if(scalar(@targetJobStatus )== 0) #if no job is running
    {$stop=0;
        }
        sleep(10);
    }
}
