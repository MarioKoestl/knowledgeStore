#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2015-04-28 14:23:11 sven>
# $Id$


use Getopt::Long;
#adjust modules folder
use lib "List-Permutor-0.022/blib/lib/";
unless(eval{require List::Permutor;}){
  print STDERR "List::Permutor Module missing! Please download, e.g. from CPAN, and install the module on your system.\n";
  exit;
}


#adjust modules folder
use lib "/home/mescalin/sven/bin/MODULES";
#load used modules
#use modulename

#adapt to each program
my $usage= << "JUS";
  usage:   FisherYates.pl [OPTIONS]
  options: -d    print debug
           -n    number of shuffled sequences [DEFAULT 1]
           -s    sequence to be shuffled [DEFAULT "ABC"]
  example: FisherYates.pl -n 2 -s 123
  results: returns a csv file separated by " " containing the 
           generated sequence, shuffled with a) a naive approach 
           b) the Fisher-Yates algorithm and c) the Sattolo cycle.

           seq naive fisher-yates sattolo
           123 0 2 0
           132 1 0 0
           213 0 2 0
           231 3 0 5
           312 2 2 1
           321 0 0 0
JUS

#adapt to used variable(s)
use strict;
#version 1 global variable(s)
use vars qw/$opt_debug $opt_seq $opt_help/;
#version 2 local (only in the programm known) variable(s)
my ($opt_num) = (1);
#a=s a must be String
#b=i b must be Integer
#d   d = 1 =>  if 'd' is defined, esle d = undef 
usage() unless GetOptions("d|debug" => \$opt_debug,
                          "s|seq=s" => \$opt_seq,
                          "n|num=s" => \$opt_num,
                          "h|help"  => \$opt_help);

if($opt_help){
  print STDERR $usage;
  exit;
}
$opt_seq = "ABC" unless($opt_seq);

################## BEGIN MAIN ##################
my @ori = split(//, $opt_seq);
my %results;
for(my $n = 1; $n<=$opt_num; $n++){
  my @naive   = @{&Naive(@ori)};
  my @fisher  = @{&FisherYates(@ori)};
  my @sattolo = @{&Sattolo(@ori)};
 
  print "naive: ", join("", @naive),"\t fisher:",join("", @fisher),"\t sattolo: ", join("", @sattolo), "\n" if($opt_debug);

  $results{join("", @naive)}->{"N"}++;
  $results{join("", @fisher)}->{"FY"}++;
  $results{join("", @sattolo)}->{"SA"}++;
 
}

&printResults(\%results);

################## BEGIN SUBS ##################

##################
# Shuffles the given array using an naive approach that creates the
# swap index always from the entiere array.
#
# Returns the shuffled array
##################
sub Naive{
  my @array = @_;
  for(my $i=0; $i<scalar(@array); $i++){
    my $j = int(rand(scalar(@array))); # 0 <= j < #elements;
    my $tmp = $array[$j];
    $array[$j] = $array[$i];
    $array[$i] = $tmp;
    print "naive ", $i,"\t",$j,"\t",join("", @array),"\n" if($opt_debug);
  }
  return(\@array);
}

##################
# Shuffles the given array using a slightly modified Fisher-Yates
# algorithm presented in Durstenfeld, Richard (July 1964). "Algorithm
# 235: Random permutation". Communications of the ACM 7 (7):
# 420. doi:10.1145/364520.364540 and suitable for an zero-based
# array. The swap index is always between 0 and the current position.
#
# Returns the shuffled array
##################
sub FisherYates{
  my @array = @_;
  for(my $i=(scalar(@array)-1); $i>0; $i--){
    my $j = int(rand(($i+1))); # 0 <= j <= i;
    my $tmp = $array[$j];
    $array[$j] = $array[$i];
    $array[$i] = $tmp;
    print "fisher ", $i,"\t",$j,"\t",join("", @array),"\n" if($opt_debug);
  }
  return(\@array);
}

##################
# Shuffles the given array using the Sattolo cycle presented in
# Sattolo, Sandra (May 1986). "An Algorithm to generate a radndom
# cyclic permutation". Information Processing Letters 22:315-317 and
# addapted for a zero-based array. The swap index is always between 0
# and one less than the current position.
#
# Returns the shuffled array
##################
sub Sattolo{
  my @array = @_;
  for(my $i=(scalar(@array)-1); $i>0; $i--){
    my $j = int(rand($i)); # 0 <= j < i;
    my $tmp = $array[$j];
    $array[$j] = $array[$i];
    $array[$i] = $tmp;
    print "sattolo ", $i,"\t",$j,"\t",join("", @array),"\n" if($opt_debug);
  }
  return(\@array);
}

##################
# Print all possible permutations of the input sequence and the count
# how often it was shuffled by the naive, Fisher-Yates and Sattolo
# Cycle approach.
# 
# Output is csv formated with " " as separator.
##################
sub printResults{
  my %hash = %{pop(@_)};
  print "seq naive fisher-yates sattolo\n";
  my $perm = new List::Permutor split(//, $opt_seq); # returns all
						     # possible
						     # permutations
						     # ignoring if a
						     # value occures
						     # several times
  # generate a uniq set of possible permutations
  my %uniqPerm;
  while (my @set = $perm->next) {
    my $seq = join("", @set);
    $uniqPerm{$seq}++ unless(exists $uniqPerm{$seq});
  }

  foreach my $seq (sort keys %uniqPerm){
    if(exists $hash{$seq}->{"N"}){
      print $seq," ",$hash{$seq}->{"N"};
    }
    else{
      print $seq," ", 0;
    }
    if(exists $hash{$seq}->{"FY"}){
      print " ",$hash{$seq}->{"FY"};
    }
    else{
      print " ", 0;
    }
    if(exists $hash{$seq}->{"SA"}){
      print " ",$hash{$seq}->{"SA"},"\n";
    }
    else{
      print " ", 0, "\n";
    }
  }
}

__END__
