#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

my $usage= << "JUS";
  Title:   kfy_mkoestl.pl
  usage:   kfy.pl -seq [sequence] -n [howMany]
  
  options: -seq|s  [REQUIRED]    sequence as string
           -n                    how many sequences should be created, default =1
           -help|h               print this message
           -verbose|v            print additional informations        
        
  results: Shuffles the given sequence keeping the nucleotide count but wihtout keeping the klet count
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



my @ensemble;
my @wrongSeq;
for(my $i = 0; $i< $n;$i++)
{
    #print kfy_shuffle($dna) ."\n";
    my $newSeq = kfy_shuffle($seq);
    push(@ensemble,$newSeq);
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




#printHash(freq(\@dna));

sub kfy_shuffle
{
    my $seq = $_[0];
    my @dna = split(//,$seq);
    my $n = scalar(@dna);
    if ($n<=1) { #shuffle not possible
        return $seq;
    }
    
    for (my $i=0;$i<$n-1;$i++)
    {
        my $r = int(($i) + rand(($n-1+1) - ($i))); # random number between $i and n-1
        ($dna[$i],$dna[$r]) = ($dna[$r],$dna[$i]);
    }
    
    return join("",@dna);
}

sub printHash
{
    my %hash = %{shift(@_)};
    foreach (sort keys %hash)
    {
        print $_ . "-->".$hash{$_}. "\n"; 
    }
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