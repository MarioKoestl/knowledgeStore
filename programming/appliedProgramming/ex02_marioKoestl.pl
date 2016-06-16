#!/usr/bin/perl

use strict;
use warnings;


sub min
{
	my $min=$_[0];  # set min to first value of arguments, will result with failure if no arguments were passed
	foreach (@_)
	{
		if($_ < $min)
		{
			$min = $_;		
		}
	}
	return $min;
}

sub count
{
	my ($seq,$s) = @_; # get arguments
	my $count=0;
	foreach (split //,$seq) # split with nothing, is every char from string
	{
		if(uc($_) eq uc($s))
		{
			$count ++;
		}
	}
	return $count;
	
}

#6
sub fact_rec #recursiv
{
	my $n = shift(@_); # get your start number
	if($n==0)
	{
		return 1;
	}else
	{
		return $n * fact($n-1);
	}
}

sub fact_it # iterative
{
	my $n = shift(@_); # get your start number
	my $ret=1;
	for(my $i=1;$i<=$n;$i++)
	{
		$ret *= $i;
	}
	return $ret;
}

#1
my @brain=(65,69,70,63,70,68);
my @heart=(102,95,98,110);
my @lung=(112,115,113,109,95,98,100);

printf "lowest activity of BRAIN:\t %6.1f \n",min(@brain);
printf "lowest activity of HEART:\t %6.1f \n",min(@heart);
printf "lowest activity of LUNG:\t %6.1f \n",min(@lung);

#2 and #3

print "insert 1. odd numbers:\n";
my $n1 = <STDIN>; chomp($n1);
print "insert 2. odd numbers:\n";
my $n2 = <STDIN>; chomp($n2);
if($n1 % 2 == 0 or $n2 % 2 == 0) { print "you inserted even numbers, program will be terminated! \n" ; exit -1;}


if($n1>$n2) # change values if $n1 > $n2
{
	my $help = $n2;
	$n2 = $n1;
	$n1 = $help;
}
my @between=();

my $i=$n1;

#2
while($i<=$n2)
{
	if($i % 2 !=0) 
	{
		push(@between,$i);
	}
	$i++;
}
print "\n array with while loop :\n", reverse @between;


@between=();
#3
for (my $i=$n1;$i<=$n2;$i++)
{
	if($i % 2 !=0) 
	{
		push(@between,$i);
	}
}

print "\n array with for loop :\n", reverse @between;

#4
my $seq = "GGTGCTAGCTACGACTAC";

my @matches = $seq =~ m/[gG]/g;   # this is alternative solution, with regex, even easier than a sub
#printf "Number of G's is:\t %i\n", scalar @matches;

printf "Number of G's is:\t %i\n", count($seq,"G");

#5 
#already done that, look at Ex01 from mario Koestl


#6 
print "insert number of factorial:  ";
my $n = <STDIN>; chomp($n);
if(int($n) != $n or $n<0) # check if input number is a valid positive interger value
{
	print "you didn't input a valid interger number, program terminated!\n";
	exit -1;
}
printf "!$n = %10.0f \n", fact_it($n);







