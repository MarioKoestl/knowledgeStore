#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2016-04-19 17:10:38 sven>
# $Id$

use Getopt::Long;
#adjust modules folder
#use lib "/home/mescalin/sven/bin/MODULES";
#load used modules
#use modulename

#adapt to each program
my $usage= << "JUS";
  usage:   perl verwaltungsverteilung_findeiss.pl [OPTIONS]
  options: -d    print debug
           -f    select input file
           -b    set boundary
           -m    select method either r using a recursive 
                 implementation or n for a naive approach
                 [DEFAULT r]
           -h    print this message
  results: 
  example: 
JUS

#adapt to used variable(s)
use strict;
#version 1 global variable(s)
use vars qw/$opt_debug $opt_help $opt_file $opt_bound/;
#version 2 local (only in the programm known) variable(s)
my ($opt_method)=("r");
#a=s a must be String
#b=i b must be Integer
#d   d = 1 =>  if 'd' is defined, esle d = undef 
usage() unless GetOptions(
  "d|debug" => \$opt_debug,
  "b|bound=i" => \$opt_bound,
  "m|method=s" => \$opt_method,
  "h|help" => \$opt_help,
  "f|file=s" => \$opt_file
    );

if($opt_help){
  print STDERR $usage; 
  exit;
}

# Read the matrix and save it into an array of cities and a hash that
# contains the specific weights. The hash contains the costs to form a
# tuple of city 1 with all subsequent ones in the array
# (e.g. weight{L} = [2, 2] for the costs to form tuples with P and S)
my @elements=();
my %weight=();
my $l = 0;
my $num_cities = 0;
open(FI, $opt_file) or die "Can't open input file ",$opt_file,"\n";

while(<FI>){
  chomp($_); # remove line break
  my @a = split(' ', $_); # split at space
  if(scalar(@a) == 2 and $a[0] =~ /\d+/ and $a[1] =~ /\d+/){
    $num_cities = $a[0];
    if($num_cities % 2 != 0){
      print "Need an even number of cities\t", $num_cities, "\n";
      exit;
    }
    $opt_bound = $a[1] unless($opt_bound);
  }
  elsif(scalar(@a) == $num_cities and join("", @a) =~ /^[A-Za-z]+$/){
    #get element names
    @elements = @a;
  }
  elsif(scalar(@a) == $num_cities){
    #parse weighting matrix
    $l++;
    for(my $i=$l; $i<@a; $i++){
      # save for each city the an array how to connect it to all other cities
      push @{$weight{$elements[$l-1]}}, $a[$i];
    }
  }
  else{
    print STDERR "ignored line: >",$_,"<\n",join("<\t>",@a),"\n";
  }
}
close(FI);

# Print the array of cities and the weight hash
if($opt_debug){
  for(my $i=0; $i< @elements; $i++){
    if(exists $weight{$elements[$i]}){
      printf STDERR "%3s", ""; for(my $j=$i+1; $j<@elements; $j++){printf STDERR "%-3s", $elements[$j];} print STDERR "\n";
      printf STDERR "%-3s", $elements[$i]; foreach(@{$weight{$elements[$i]}}){ printf STDERR "%-3s", $_;} print STDERR "\n\n";
    }
  }
}

my $bound = $opt_bound;

if($opt_method eq "n"){
  &naive(\@elements, [], 0);
}
else{
  &recursion(\@elements, [], 0, 0);
}


# implements a depth first search that doesn't keep track of already
# found solutions.
sub naive{
  my @cities = @{shift(@_)};
  my @tuples = @{shift(@_)};
  my $costs  = shift(@_);
  
  my @states = [\@cities, \@tuples, $costs];
  while(@states){
    my $state = pop(@states);
    print STDERR "Remaining Cities: ",join(",", @{$state->[0]}),"\tTuples: (",join(")(", @{$state->[1]}),")\tCosts: ",$state->[2],"\n" if($opt_debug);
    if($state->[2] <= $bound){
      my @tuples = @{&generateTuples(@{$state->[0]})};
      if(@tuples){
	foreach (@tuples){
	  my $costs = $state->[2]+$weight{$_->[0]}->[&getIndexDifference(\@elements, $_->[0], $_->[1])-1];
	  if ($costs < $bound or ($costs == $bound and (scalar(@{$state->[0]})-2) == 0)){
	    my @set = @{$state->[0]};
	    splice(@set, &getIndex(\@set,$_->[0]),1); # remove the first element of the taken tuple 
	    splice(@set, &getIndex(\@set,$_->[1]),1); # remove the second element of the taken tuple 

	    #extend the known list of tuples by the new one
	    my @tup = @{$state->[1]}; 
	    push(@tup, $_->[0].",".$_->[1]);

	    #store the valid state
	    push(@states, [\@set, \@tup, $costs]);
	  }
	  else{
	    printf STDERR "Cgth Tuples: %-5s and %-20s Costs: %-5d\n", "(".join(",",@{$_}).")", "(".join(")(", @{$state->[1]}).")",$costs if($opt_debug);
	    next;
	  }
	}
      }
      else{
	my @sol = sort(@{$state->[1]});
	print $state->[2]," Mio. Euro/Jahr: (",join(")(", @{$state->[1]}),")\n";
      }
    }
  }
}

# this function generates possible tuples of the first element of an
# array and all remaining elements
# (A, B, C, D) => {(A,B); (A,C); (A,D)}
sub generateTuples{
  my @a = @_;
  my @r = ();
  for(my $i=1; $i<@a; $i++){
    push(@r, [$a[0], $a[$i]]);
  }
  print STDERR "possible tuples:\t",&printTuples(\@r),"\n" if($opt_debug);
  return \@r;
}

# given two elements $e1 and $e2 and the array @a that should contain
# those two this function returns how far they are apart by means of
# their indecies within the array
sub getIndexDifference{
  my @a = @{shift(@_)};
  my $e1 = shift(@_);
  my $e2 = shift(@_);
  my ( $i1 ) = grep { $a[$_] =~ /$e1/ } 0..$#a;
  my ( $i2 ) = grep { $a[$_] =~ /$e2/ } 0..$#a;

  if(defined $i1 and defined $i2){
    return abs($i2-$i1);
  }
  else{
    print STDERR "Could not claculate index difference of ",$e1," and ",$e2 ," as one is not in \{",join(",", @a),"\}\n";
    exit;
  }
}

# takes an array of tuples ($a[i]=[t1,t2]) and returns a nicely
# formated string
sub printTuples{
  my @tuples = @{shift(@_)};
  my $string="";
  foreach (@tuples){
    $string .= "(".$_->[0].",".$_->[1].")";
  }
  return $string;
}

# given a certain element $e this function returns its index in the
# array @a or prints an error if the $e is not found in @a
sub getIndex{
  my @a = @{shift(@_)};
  my $e = shift(@_);
  my ( $i ) = grep { $a[$_] =~ /$e/ } 0..$#a;
  if(defined $i){
    return $i;
  }
  else{
    print STDERR "Could not find ",$e," in \{",join(",", @a),"\}\n";
    exit;
  }
}


# implements a recursive function
sub recursion{
  my @cities = @{shift(@_)};
  my @tuples = @{shift(@_)};
  my $costs  = shift(@_);
  my $counter = shift(@_);
  
  $counter++;
  
  printf STDERR "Cur => Recursion: %-3d Cities: %-20s Tuples: %-20s Costs: %-5d\n", $counter, join(",", @cities),&printTuples(\@tuples),$costs if($opt_debug);
  if(scalar(@cities) == 0){
    print($costs," Mio. Euro/Jahr: ", &printTuples(\@tuples), "\n");
  }
  else{
    #get first partner of the tuple if cities are left
    my $first = shift(@cities);
    #get second partner for the tuple and update costs
    foreach my $second (@cities){
      my $money = $costs + $weight{$first}->[&getIndexDifference(\@elements, $first, $second)-1];
      #check if costs are to high or not all cities are in the solution
      if($money > $bound or ($money == $bound and scalar(@cities)>1)){
	printf STDERR "Cgth => Recursion: %-3d Tuples: %-20s Costs: %-5d\n",$counter, &printTuples(\@tuples)."(".$first.",".$second.")",$money if($opt_debug);
	next;
      }
      my @pairs = @tuples;
      push(@pairs, [$first,$second]);
      my @set = @cities;
      splice(@set, &getIndex(\@set,$second),1);
      &recursion(\@set, \@pairs, $money, $counter);
    }
  }
}

__END__
