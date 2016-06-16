#!/usr/bin/perl
package Bioinformatics::Pattern;


use warnings;
use strict;


#############################
###getFastaSeqs###
#Reads reference to Array stored with all found fasta Sequences
#input 1[string] FilePath : path to input FastaFile
#return 1: array filled with fasta sequences
#############################
sub getFastaSeqs
{
    my $filePath = shift(@_);
    
    my @retArray=();
    open(my $fh, "<", $filePath) || die "Couldn't open '".$filePath."' for reading because: ".$!;
    my $seq="";
    while(my $line = <$fh>){
        chomp($line);
        #print " NOW WE ARE AT LINE \t$line\n";
        if ($line =~ /^>/) { # is fasta header
            if ($seq ne "") {
                #print "NOW PUSHED $seq to ARRAY\n";
                push(@retArray,$seq);
                $seq="";
            }
        }else
        {
            $seq .= $line;
        }
    }
    if ($seq ne "") { # Push seq to array if there is only one fasta seq in file
        #print "NOW PUSHED $seq to ARRAY\n";
        push(@retArray,$seq);
    }
    
    close($fh);
    return \@retArray;
}

#############################
###getPatternMatchPositions
##Finds every position of occurence in the givn DNA sequence of the inputed Pattern
##input 1[string] sequence: nucleotide sequence to look for Pattern
##input 2[string] regex pattern to search for
##input 3[string, OPTIONAL] : TRUE or FALSE if dna sequence is circular, default = FALSE
#return 1: Array filled with all sorted positions(first char on DNA strand =1) of the found pattern 
#############################
sub getPatternMatchPositions
{
    my %args = @_;
    my $seq = $args{"sequence"};
    my $pattern = $args{"pattern"};
    my $is_circular=$args{"is_circular"};
    my @pos;
    
    if($is_circular)
    {
        if ($is_circular eq "TRUE") { # take the length of the apttern and add it to the end of the sequence 
            $seq .= substr($seq,0,6)."\n";   # maybe take the real length of the pattern and not the hardcoded 6
        }
    }
    while ($seq =~ /$pattern/gi) { 
        push(@pos,$-[0]+1); #$-[0]+1  is the position of the first char of the matched pattern
    }
    return @pos;

}


return 1;