#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2016-05-25 11:47:01 sven>
# $Id$


use Getopt::Long;
use Test::More; # tests => 2;
use Data::Dumper;
no warnings 'recursion';
#adjust modules folder
use lib "/home/mescalin/sven/bin/MODULES";
#load used modules
#use modul;

#adapt to each program
my $usage= << "JUS";

  This script solves the efficient mass decomposition problem, which is
  an extension of the Coin Exchange Problem using the Dynamic
  Programming algorithm described in "Efficient Mass Decomposition",
  Sebastian Boecker and Zsuzsanna Liptka, ACM Symposium on Applied
  Computing, 2005. In contrast to the classical dynamic programming
  approach it calculates in a memory efficient way all possible
  solutions instead of the best solution(s) only.

  usage:   MassSpec.pl [OPTIONS]
  options: -d    print debug messages
           -N    mass value to be explained [DEFAULT 99]
           -S    standard values [DEFAULT 1:2:5:10:20:50]
           -T    do unit tests
           -h    print this message

JUS

#adapt to used variable(s)
use strict;
#version 1 global variable(s)
use vars qw/$opt_debug @C $M @results $opt_Test $opt_help/;

#initialize global variable
@C = qw/1 2 5 10 20 50/;
$M = 99;

#version 2 local (only in the program known) variable(s)
#my (...);
#a=s a must be String
#b=i b must be Integer
#d   d = 1 =>  if 'd' is defined, else d = undef 
usage() unless GetOptions("d|debug" => \$opt_debug,
			  "N=i"  => \$M,
			  "S=s"  => sub{@C = sort {$a<=>$b} split(':', $_[1])}, 
                                          # split input string at ":", 
			  "Test|t" => \$opt_Test,
			  "h|help" => \$opt_help
);

#debug message will be printed on standard-error if opt_debug is defined
if($opt_help){
  print STDERR $usage;
  exit;
}

unless($opt_Test){
  # remove all numbers <= 0 and remove all duplicates using a hash
  my %hash=();
  foreach my $c (@C){
    next if($c<=0);
    $hash{$c}++;
  }
  @C = sort {$a<=>$b} keys(%hash);

  print "I'll use mass: ", $M, " and standard units are: ",join(" ", @C),"\n";
  print "Number of possible solutions: ",&count(scalar(@C), $M, @C),"\n";
  my @Matrix = &FillDPMatrix($M, @C);
  print "Do backtracking\n";
  my @tmp = ();
  &backtrack((scalar(@C)-1), $M, \@C, \@Matrix, \@tmp);
  print "Found ",scalar(@results)," results\n";
  for(my $i=0; $i<@results; $i++){
    print "Result_",($i+1),":\t",join("\t",@{$results[$i]}),"\n";
  }
}


###
# takes: the actual mass and an array of standard units
#
# returns: the filled dynamic programming matrix (Boolean values only)
###
sub FillDPMatrix{
  my $mass = shift(@_);
  my @aa = @_;
  my @dpm;
  
  print STDERR "Used in FillDPMatrix: The standard units are ", join(" ", @aa)," and the mass is ",$mass,"\n" if($opt_debug);

  
  for(my $i=0; $i<@aa; $i++){
    my @line;
    for(my $m=0; $m<=$mass; $m++){
      #first line is initialized with 1 if the sub-mass m mod the
      #current standard unit is 0 and 0 otherwise
      if($i==0){
	if($m % $aa[$i] == 0){
	    $line[$m]=1;
	}
	else{
	  $line[$m]=0;
	}
      }
      #in all other lines we fill 1 if the value one line above or the
      #value at (sub-mass m - the current standard unit) is 1
      else{
	if($dpm[$i-1]->[$m] or $line[$m-$aa[$i]]){
	  $line[$m]=1;
	}
	else{
	  $line[$m]=0;
	}
      }
    }
    push(@dpm, \@line);
  }
  #print DPM in debug mode
  if($opt_debug){
    print STDERR "Dynamic Programming Matrix:\nC/N\t";
    for(my $i=0; $i<@{$dpm[0]};$i++){
      print STDERR $i,"\t";
    }
    print STDERR "\n";
    for(my $i=0; $i<@dpm; $i++){
      print STDERR $aa[$i],"\t",join("\t",@{$dpm[$i]}),"\n";
    }
  }
  return(@dpm);
}


###
# takes: the line index i, the mass to be explained, the standard
# units, the filled DP matrix and the an array containing a possible
# solution
#
# does: recursive calculation of the mass in question. Temporary
# result is stored in the array of a possible solution and if the mass
# to be explained is zero the possible solution is copied into the
# global result array.
###
sub backtrack{
  my $line = shift(@_);
  my $mass = shift(@_);
  my @aa = @{shift(@_)};
  my @dpm = @{shift(@_)};
  my @tmp = @{shift(@_)};
  
  if($dpm[$line]->[$mass]){
    if($mass == 0){
      push(@results, \@tmp);
    }
    else{
      if($dpm[$line]->[$mass - $aa[$line]]){
	my @t = @tmp;
	push(@t, $aa[$line]);
	&backtrack($line, ($mass-$aa[$line]), \@aa, \@dpm, \@t);
      }
      if(($line-1) >= 0 and $dpm[$line-1]->[$mass]){
	&backtrack(($line-1), $mass, \@aa, \@dpm, \@tmp);
      }
    }
  }
}

# Count the number of possible solutions to generate mass n with the
# given unit values
# (http://www.geeksforgeeks.org/dynamic-programming-set-7-coin-change/)
# The method works with a array of size n+1 which is updated.
sub count{
  my $m = shift(@_); #size of the unit-value array
  my $n = shift(@_); #the mass to be explained
  my @S = @_;        #the unit-value array
  
  my @table= ((0) x ($n+1));
  $table[0] = 1;
  if($opt_debug){print STDERR "C/N\t\t"; for(my $j=0; $j<=$n; $j++){print STDERR $j,"\t";}print STDERR "\n";}
  for(my $i=0; $i<$m; $i++){
    for(my $j=$S[$i]; $j<=$n; $j++){
      $table[$j] += $table[$j-$S[$i]];
    }
    print STDERR "array after ",$S[$i],":\t",join("\t", @table),"\n" if($opt_debug);
  }
  return $table[-1];
}


# Do testing if wanted
if($opt_Test){
  
  # test if the calculated number of possible solutions is correct for
  # a set of handcrafted stuff
  
  subtest 'Test Count number of possible solutions' => sub {
    my @c = qw/2 5 7/;
    my $m = 3;
    ok(0==&count(scalar(@c),$m,@c), "test if number is 0");
    $m = 5;
    ok(1==&count(scalar(@c),$m,@c), "test if number is 1");
    $m = 10;
    ok(2==&count(scalar(@c),$m,@c), "test if number is 2");
    $m = 12;
    ok(3==&count(scalar(@c),$m,@c), "test if number is 3");
    $m = 14;
    ok(4==&count(scalar(@c),$m,@c), "test if number is 4");

    done_testing();
  };

  # test if the DP Matrix is filled correctly for a given example if
  # the two matrices do not match an additional test for each line of
  # the matrices is done

  subtest 'Test FillDPMatrix' => sub {
    my @c = qw/2 5 7/;;
    my $m = 10;
    my @cmp = ([1,0,1,0,1,0,1,0,1,0,1], 
	       [1,0,1,0,1,1,1,1,1,1,1], 
	       [1,0,1,0,1,1,1,1,1,1,1]);
    my @filled = &FillDPMatrix($m,@c);
    unless(ok(eq_array(\@filled,\@cmp), "compare the complete matrix")){
      for(my $i=0; $i<@cmp; $i++){
	unless(ok( eq_array($filled[$i],$cmp[$i]), "test line $i of the matrix")){
	  print join("\t", @{$filled[$i]}),"\n",join("\t",@{$cmp[$i]}),"\n";
	}
      }
    }
    done_testing();
  };

  # Generate 20 random inputs and test if the backtracking routine
  # works as intended:
  # 1) check if the number of results is equal to the number of possible results
  # 2) check if the sum of the unit values of each result is equal to the mass to be explained

  subtest 'Test Backtracking' => sub {
    @results = ();
    for(my $x=0; $x<20; $x++){
      my $rm = int(rand(400))+1;
      my $n = int(rand(10))+1;
      my @rAA = ();
      for(my $i=0; $i<$n; $i++){
	push(@rAA, int(rand(90))+1);
      }
      @rAA = sort {$a<=>$b} keys {map { $_ => 1 } grep (!/[0|\-]/, @rAA)};

      print "random Mass = ",$rm, "\t AA masses: ",join(" ", @rAA),"\n"; 
      my @mat=&FillDPMatrix($rm,@rAA);
      my @tmp = ();
      &backtrack((scalar(@rAA)-1), $rm, \@rAA, \@mat, \@tmp);
      
      my $pos = &count(scalar(@rAA), $rm, @rAA);
      ok($pos == scalar(@results), "test if the number of found solutions ".$pos." is equal to the generated count ".scalar(@results)."\n");
      $x-- unless($pos);
      foreach my $res (@results){
	my $sum = eval join '+', @{$res};
	ok($sum == $rm, "test if sum is equal to mass $rm\t".join("\t", @{$res})."\n");
      }
      
      @results=();
    }
    done_testing();
  };
  done_testing(2);
}

__END__

Test: what happens if a unit value is entered twice 
Test: what happens if a unit value < 1 is entered
Test: if the number of sollutions matches the estimate

