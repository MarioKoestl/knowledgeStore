#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $usage= << "JUS";
  Title:   wuerfeln_mkoestl.pl
  usage:   wuerfeln.pl -seq [sequence] -n [howMany]
  
  options: -seq|s  [REQUIRED]    sequence as string
           -n                    how many sequences should be created, default =1
           -help|h               print this message
           -verbose|v            print additional informations        
        
  results: Shuffles the given sequence and keeping the nucleotide count only on average but without keeping the klet count
JUS



my $opt_help;
my $seq;
my $opt_v;
my $n=1;

GetOptions(
  "h|help|" => \$opt_help,
  "seq|s=s" => \$seq,
  "n=i" => \$n,
  "verbose|v" => \$opt_v);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}
if (!$seq) {
    print $usage;
    exit;
}


my %freq_int = freq_int($seq);

#printHash(freq($seq));
my @ensemble;

for(my $i = 0; $i< $n;$i++)
{
    push(@ensemble,freqEsti($seq,\%freq_int));
}



my %countHash;
foreach (@ensemble)
{
    if ($countHash{$_})
    {
        $countHash{$_} += 1;
    }else
    {
        $countHash{$_}=1;
    }
}

print("\n\nIF sequence $seq with a nucleotide count of : \n");
printHash(freq($seq));
print("\nwas shuffled.......\n");
print "....",scalar(keys %countHash)," solutions were found :\n\n";
foreach (keys %countHash)
{
    print "$_ -> ",$countHash{$_},"\n";
    if ($opt_v) {
        printHash(freq($_));
    }
    
}
print"\nSTATISTICS ....\n";
my @values = values %countHash;

print "Average = ",&average(\@values),"\n";
print "Std = ",&stdev(\@values),"\n";
print "Variance = ",sqrt(&stdev(\@values)),"\n";

print "The nucleotide frequency on average is listed below, and should be the same as the frequency of the given sequence";
print "\n";
printHash(freq_ensemble(\@ensemble));


sub freqEsti
{
    my $seq = shift(@_);
    my %hash = %{shift(@_)};
    my $newSeq="";
    my $r;
    
    for(my $i=0; $i< length($seq); $i++)
    {
        $r= rand(); # rand number between 0 and 1
        foreach my $nuc (keys %hash)
        { 
            my $begin = (split(/-/,$hash{$nuc}))[0];
            my $end = (split(/-/,$hash{$nuc}))[1];
            if ($r >= $begin and $r <= $end) {
                $newSeq .= $nuc;
            }
            
        }
    }
    return $newSeq;
    
}




sub printHash
{
    my %hash = %{shift(@_)};
    foreach (sort keys %hash)
    {
        print $_ . "-->".$hash{$_}. "\n"; 
    }
}


#creates the frequency_interval hash, counts the frequency of each nucleotide in the sequence
#example seq of ACGUA will lead to this hash
#A-->0.4-0.8
#C-->0.2-0.4
#G-->0.8-1
#U-->0-0.2
sub freq_int
{
    my %hash;
    my @dna = split(//,shift(@_));
    
    foreach (@dna)
    {
        if ($hash{$_}) {
            $hash{$_} += 1/scalar(@dna);
        }else
        {
            $hash{$_} = 1/scalar(@dna);
        }
    }
    
    my $z=0;
    foreach my $key (keys %hash)
    {
        
        my $help = $hash{$key};
        $hash{$key} = $z."-".($hash{$key}+$z);
        $z += $help;
    }
    
    return %hash;
}
#creates the frequency hash, counts the frequency of each nucleotide in the sequence
sub freq
{
    my %hash;
    my @dna = split(//,shift(@_));
    
    foreach (@dna)
    {
        if ($hash{$_}) {
            $hash{$_} += 1/scalar(@dna);
        }else
        {
            $hash{$_} = 1/scalar(@dna);
        }
    }
    return \%hash;
}
#creates the frequency hash, counts the frequency of each nucleotide in all sequences
sub freq_ensemble
{
    my %hash;
    my @seqs = @{shift(@_)};
    
    foreach my $seq (@seqs)
    {
        foreach (split(//,$seq))
        {
            if ($hash{$_}) {
                $hash{$_} += 1/(length($seq)*scalar(@seqs));
            }else
            {
                $hash{$_} = 1/(length($seq)*scalar(@seqs));
            }
        }
    }
    return \%hash;
}

sub average{
        my($data) = @_;
        if (not @$data) {
                die("Empty arrayn");
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}