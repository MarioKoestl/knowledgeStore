#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $usage= << "JUS";
  
  usage:   wgp_mkoestl_ex03.pl -max[maxAmount] -coins [coin Values]
  
  options: -max|m  [REQUIRED]     Value of return money [int] 
           -help|h                print this message
           -coins|c  [REQUIRED]    [string] of available coin Values, separeted by ,
                                  ex. 1,5 . to allow 1 and 5 money pieces
           -verbose|v print additional informations        

  results: Print the minimal amount of coins to achieve the given maxAmount. Dynamically Programmed
JUS



my $opt_help;
my $opt_max;
my $opt_coins;
my $opt_verbose;

GetOptions(
  "h|help|" => \$opt_help,
  "max|m=i" => \$opt_max,
  "coins|c=s" => \$opt_coins,
  "verbose|v" => \$opt_verbose);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (!$opt_max or !$opt_coins) {
    print $usage;
    exit;
}




my $maxN= $opt_max;
my @coins = split(/\,/,$opt_coins);

my @amount =(9**9**9)x($maxN+1); #+1 for the 0, value for starting stores for every value from 0 to maxN the min amount of coins to make this maxN


$amount[0]=0; # initialize the array

for(my $i=1; $i <= $maxN ; $i++)
{
    foreach my $coin (@coins)
    {
        if ($coin <= $i) { # the coin we tried is smaller than the max amount of money we are right now,we don't have to try 50 cent for maxN of 10cent
            # @amount[$i-$coin] = last best solution wereby we can add our current Coin to the this solution and do not extend the current maxN
            if (($amount[$i-$coin] +1) < $amount[$i]) { #adding this coin would be better than our current solution
                $amount[$i] = $amount[$i-$coin] +1; # than add this coin               
            }
        }
    }
}



my @solution=();
my $curPos=$maxN;

while ($curPos>0) { # or make recursiv
    foreach my $coin (@coins)
    {
        if ($coin <= $maxN) {
            if (($amount[$curPos-$coin]+1) == $amount[$curPos]) { # check if to get to the current POsition the current Coin could be part of the best solution
                push(@solution,$coin);
                $curPos -= $coin;
            }
        }
    }
}



my %solHash =createHash(\@solution);

if ($opt_verbose) {
    print "\nMinValueTable =\n";
    for(my $i=1; $i <= $maxN ; $i++)
    {
        print "$i \t $amount[$i]\n";
    }
print "\nSolutionPath = @solution  \n";
}
print "\nSolutionHash to achieve $maxN:\n";
foreach my $key (sort {$b <=> $a} keys %solHash) {
	print " $solHash{$key} X $key coin\n";
}


sub createHash
{
    my @array = @{shift(@_)};
    my %hash;
    
    foreach (@array)
    {
        $hash{$_} +=1;
    }
    
    return %hash;
}


