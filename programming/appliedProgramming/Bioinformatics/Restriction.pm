#!/usr/bin/perl
package Bioinformatics::Restriction;
use warnings;
use strict;

#############################
###getFragmentLengths
##gets the sorted length of dna fragments for a given list of cur positions
##input 1[ref array] pos_array: array of cut positions
##input 2[int] seq_length : length of dna sequence to cut
##input 3[string, OPTIONAL] : TRUE or FALSE if dna sequence is circular, default = FALSE
#return 1: Array filled with all sorted fragments after cuts were taken according to pos_array
#############################
sub getFragmentLengths
{
    my %args = @_;
    my @pos = @{$args{"pos_array"}};
    my $length = $args{"seq_Length"};
    my $is_circular="FALSE";
    
    if($args{"is_circular"})
    {
        $is_circular = $args{"is_circular"};
    }
    
    my @frags;
    my $start;
    
    if ($is_circular eq "TRUE")
    {
        $start=$pos[0];
        for(my $i=1;$i<scalar(@pos);$i++)
        {
            push(@frags,$pos[$i]-$start);
            $start = $pos[$i];
        }
        push(@frags,$length-$start + $pos[0]); # now include the remaining part until the first cut position= circle
        
    }elsif($is_circular eq "FALSE")
    {
        $start=0;
        foreach (@pos)
        {
            push(@frags,$_-$start); 
            $start = $_; 
        }
        push(@frags,$length-$start); # also take the last fragment
    
    }
    return sort {$a <=> $b } @frags;
    
    
}   




return 1;