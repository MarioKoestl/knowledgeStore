#!/usr/bin/perl
# -*-Perl-*-
# Last changed Time-stamp: <2016-05-24 21:57:56 sven>
# $Id$
#
# Literature:
# Ullmann, JR "An Algorithm for Subgraph Isomorphism".
# Journal of the Association for Computing Machinery, Vol 23, No.1,
# January 1976, pp 31-42.
#

use strict;

use Data::Dumper;
use Getopt::Long;
#adjust modules folder
use lib "Math-Matrix-0.8/blib/lib/";
unless(eval{require Math::Matrix;}){
  print STDERR "Math::Matrix Module missing! Please download, e.g. from CPAN, and install the module on your system.\n";
  exit;
}
use lib "List-Permutor-0.022/blib/lib/";
unless(eval{require List::Permutor;}){
  print STDERR "List:Permutor Module missing! Please download, e.g. from CPAN, and install the module on your system.\n";
  exit;
}

#adapt to each program
my $usage= << "JUS";

  usage:   perl ullmann_sven.pl INPUT1 INPUT2
  options: -h    print this message
           -d    print debug messages
           -r    activate full Ullmann reduction
  results: Returns the number of possible 
           subgraph isomorphisms and all corresponding 
           embeddings. The implemented algorithm is based 
           on the publication by Ullmann 1976.

  Literature:
    Ullmann, JR "An Algorithm for Subgraph Isomorphism".
    Journal of the Association for Computing Machinery, Vol 23, No.1,
    January 1976, pp 31-42.

JUS

#adapt to used variable(s)
use strict;
#version 1 global variable(s)
use vars qw/$opt_debug $opt_help $opt_reduce @RES $M0 @univec/;
#version 2 local (only in the programm known) variable(s)
#my (...);
#a=s a must be String
#b=i b must be Integer
#d   d = 1 =>  if 'd' is defined, esle d = undef 
usage() unless GetOptions("d|debug" => \$opt_debug,
                          "h|help"  => \$opt_help,
                          "r|reduce"=> \$opt_reduce);


do{print $usage; exit;} if($opt_help); # print help if wanted and exit


# Read the molecules encoded in the input files
# the coorsponding data structure looks like 
# G{vertex index} = [vertex label, [row of adjacency matrix], edge type
my $Q = &read_molecule();
my $T = &read_molecule();
($Q, $T) = ($T, $Q) if keys %$Q > keys %$T; # make smale molecule the
					    # query graph
&dump_lol("S1", &create_adj_matrix($Q));
&dump_lol("S2", &create_adj_matrix($T));

# build embeding matrix
$M0 = &build_M_0($Q, $T); # create a matrix that is not fully reduced yet
&dump_lol("M0 initial", $M0);
do{$M0 = &reduce_M_0($Q,$T,$M0); &dump_lol("M0 reduced", $M0); } if($opt_reduce); # create the fully reduce matrix

# fill array with possible unit vectors of which the size is equal to
# the number of vertices in the larger graph
&fillUnitVec(scalar(keys %$T)); # writes to global variable @unitvec

# find graph isomorphisms
&findIsos($Q,$T,$M0,0);

print "found ",scalar(@RES)," subgraph isomorphism(s).\n";
foreach my $res (@RES){
  print "[",join(", ",@{$res}),"]\n";
}

############################################
################### SUBS ###################
############################################

# Takes the querry graph representations, the embeding matrix and the
# current depth to generate all possible embedings and test them. If
# an valid embeding is found it is added to the global results array
sub findIsos{
  my ($Q,$T,$M1,$depth) = @_;
  
  if(&isEmbedding($M1)){
    &dump_lol("Possible embeding ", $M1) if($opt_debug);
    # B == M1 x (M1 x A)^T    
    # B is adjacency matrix of Querry
    # A is adjacency matrix of Target
    
    my $matM1 = new Math::Matrix(@$M1);
    my $matA = new Math::Matrix(@{&create_adj_matrix($T)});
    my $matB = new Math::Matrix(@{&create_adj_matrix($Q)});

    my $matT = $matM1;
    $matT=$matT->multiply($matA);
    $matT = $matT->transpose();
    my $matR = $matM1;
    $matR = $matR->multiply($matT);

    if($matR->equal($matB)){
      &dump_lol("Is valid embeding ", $M1) if($opt_debug);
      my @result = ();
      # write indeces of the larger graph that embed the smaller one into an array
      for(my $l=0; $l<scalar(@{$M1}); $l++){
	for(my $c=0; $c<scalar(@{$M1->[$l]}); $c++){
	  if($M1->[$l][$c] == 1){
	    push (@result,$c);
	  }
	}
      }
      push (@RES, \@result); #writes to global variable @RES
    }
  }
  elsif(&containsEmbedding($M1)){
    &dump_lol("Contains embeding ", $M1) if($opt_debug);
    my $M2 = &deep_copy_mat($M1);
    for(my $j=0; $j<scalar(@{$M0->[$depth]});$j++){
      if($M0->[$depth][$j] == 1){
	$M2->[$depth] = $univec[$j];
	&findIsos($Q,$T,$M2,($depth+1));
      }
    }
  }
}



# Tests if each row of M contains exactly on entry with a 1 and that each
# column contains at most one entry with a 1.
#
# returns 1 if we have a valid embedding candidate matrix and 0 else
sub isEmbedding{
  my $M = shift(@_);
  my $b = 1;
  my @cs = ();
  foreach my $l (@$M){
    $b = 0 if(&degree($l) != 1); #check line contains just one entry equal to 1
    for(my $j=0; $j<scalar(@$l); $j++){
      $cs[$j]++ if($l->[$j]==1);
    }
  }
  foreach my $c (@cs){
    $b = 0 if($c > 1); #check colum contains at maximum one entry equal to 1
  }
  return $b;
}



# Tests if at least one row has more than one entry equal to 1 and no
# line consists of 0s only
#
# returns 1 if an embedding is possible and 0 else
sub containsEmbedding{
  my $M = shift(@_);
  my $b = 1;
  my $counter = 0;
  foreach my $l (@$M){
    $b = 0 if(&degree($l)==0);  #it is not allowed to have a row with zeros only
    $counter++ if(&degree($l)>1);
  }
  $b=0 if($counter == 0); #either it is an embeding or not but it does not contain any others 
  return $b;
}


# reads the input file
# and returns the following data structure:
# G{vertex index} = [vertex label, [row of adjacency matrix], edge type]
sub read_molecule {
  local $_;
  my %M = ();
  while (<>) {
    next if m/^\s*$/;    # ignore empty lines
    next if m/^\#\s{2}/; # ignore top ascii graphics
    parse_vertices(\%M) if m/^\#\sKnoten/;
    parse_edges(\%M) if m/^\#\sKanten/;
    last if eof;
  }
  return \%M;
}

# if the "# Knoten" was found we parse the next lines acordingly and
# initialize entry in the graph hash G
#  
# G{vertex index} = [vertex label, [row of adjacency matrix], edge type]
sub parse_vertices {
  local $_;
  my $G = shift();
  my $num_v = $1 if ($_=<>) =~ m/^(\d+)$/; # if a line with just one digit is found it gives the number of vertices
  my $v = $num_v;
  do {
    $G->{$1} = [$2,[((0) x $v)],'-'] if ($_=<>) =~ m/^(\d+)\s+(\w+)$/; # parse the vertex index and its label
  } while --$num_v > 0;
}

# if the "# Kanten" was found we parse the next lines acordingly and 
# fill the data into graph hash G
sub parse_edges {
  local $_;
  my $G = shift;
  my $num_e = $1 if ($_=<>) =~ m/(\d+)/; # if a line with just one digit is found it gives the number of edges
  do {
    $G->{$1}[1][$2] = 1, $G->{$2}[1][$1] = 1 # flip the adjacency matrix entries to 1
        if ($_ = <>) =~ m/(\d+)\s+(\d+)\s+(\S+)/; # parse the vertex indices of the edge and the corresponding edge label
    $G->{$1}[2] = $3; # memorize the edge label
  } while --$num_e > 0;
}

# Set M_ij = 1 to 0 if not all neighbors of vertex i can be embeded on
# neighbors of vertex j. 
#
# \forall x (A_ix = 1 \Rightarrow \exists y (M_xy * B_yj = 1))
#
# We have to check all possible mappings of A_ix to B_yj.
sub reduce_M_0(){
  my %A = %{shift(@_)};
  my %B = %{shift(@_)};
  my @M = @{&deep_copy_mat(shift(@_))};
  
  my $changed = 0;
  $changed = 1 if($opt_reduce);
  # refine M until an iteration has been reached where no change happend
  while($changed){
    $changed = 0;
    for(my $i = 0; $i<scalar(@M); $i++){ # rows
      for(my $j = 0; $j<scalar(@{$M[$i]}); $j++){ # collumns
	if($M[$i]->[$j] == 1){
	  my @k = (); #indices of neighbors of the vertex in the querry graph
	  for(my $n=0; $n<scalar(@{$A{$i}->[1]}); $n++){
	    push(@k, $n) if($A{$i}->[1][$n] == 1);
	  }
	  my @p = (); #indices of neighbors of the vertex in the target graph
	  for(my $n=0; $n<scalar(@{$B{$j}->[1]}); $n++){
	    push(@p, $n) if($B{$j}->[1][$n] == 1);
	  }
	  # Generate all possible pairs how to map the neighbors of
	  # the querry vertex i to the neighbors of target vertex j
	  #
	  # Keep the list of neighbors of vertex i fix and compare it
	  # with all possible permutations of the neighbor list of
	  # vertex j. 
	  my $possible = 0;
	  my $permutor = List::Permutor->new(@p);
	  while ( my @permutation = $permutor->next() ) {
	    my $bool=1;
	    for(my $x=0; $x<scalar(@k); $x++){
	      $bool *= $M[$k[$x]]->[$permutation[$x]] * $B{$permutation[$x]}->[1][$j];
	    }
	    $possible = 1 if($bool);
	  }
	  # If non of the combinations works vertex i can't be embeded on vertex j
	  unless($possible){
	    $M[$i]->[$j] = 0;
	    $changed = 1;
	  }
	}
      }
    }
  }
  return (\@M);
}

# Uses the graph representations and the adjacency marix A of target
# graph with size n x n and adjacney matrix B of the query graph m x m
# and fills the initial embeding matrix M0 of size n x m
#
# M0 = [ [], [], ... ];
# Mij = { 1 if (deg(Tj) >= deg(Qi)) && (lable Tj equals lable Qi); 0 else }
sub build_M_0 {
  my ($S1, $S2) = @_;
  my @M = ();
  foreach my $a1 (sort {$a<=>$b} keys %$S1) {
    my $l1 = $S1->{$a1}[0];           # atom1 label
    my $d1 = degree($S1->{$a1}[1]);   # degree of atom1
    my @row = ();
    foreach my $a2 (sort {$a<=>$b} keys %$S2) {
      my $l2 = $S2->{$a2}[0];         # atom2 label 
      my $d2 = degree($S2->{$a2}[1]); # degree of atom2
      if (($d2 >= $d1) && ($l1 eq $l2)) {
	push @row, 1;
      }
      else {
	push @row, 0;
      }
    }
    push @M, [@row];
  }
  return \@M;
}

# Gets a number n and fills the global univec array with n unit
# vectors of size n
sub fillUnitVec{
  my $cols = shift(@_);
  for(my $j = 0; $j<$cols; $j++){
    my @t = ((0) x $cols);
    $t[$j] = 1;
    push(@univec, \@t);
  }
  &dump_lol("Unit Vectors", \@univec) if($opt_debug);
}

# Takes one line of an adjacency matrix, which is an array filled with
# 0 and 1, and returns the number of 1's, which is equal to the degree
# of the vertex corresponding to the line
sub degree { scalar grep {$_ == 1} @{shift()} }

# Creates a deep copy of a matrix
sub deep_copy_mat { my @m=(); push @m, [@$_] foreach @{shift()}; \@m }


# Takes the 
#
# G{vertex index} = [vertex label, [row of adjacency matrix], edge type] 
#
# object and prints the adjaceny matrix.
sub create_adj_matrix {
  my ($s) = @_;
  my @s = ();
  push @s, $s->{$_}[1] for sort {$a<=>$b} keys %$s;
  return \@s;
}

# Prints a given string (first argument) and a given matrix (second argument)
sub dump_lol {
  print shift(), "\n";
  print join(" ", @$_), "\n" for @{shift()};
  print "\n";
}




__END__


for I in {1,2,3,4}; do a=$(echo "result0"$I".txt"); perl ullmann.pl target0$I.txt query0$I.txt > $a; done
for I in {1,2,3,4}; do a=$(echo "sven0"$I".txt"); perl ullmann_sven.pl target0$I.txt query0$I.txt > $a; done
for I in {1,2,3,4}; do echo "Case "$I; diff result0$I.txt sven0$I.txt; done
