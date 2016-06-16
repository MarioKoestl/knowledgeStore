#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2016-05-03 14:12:23 sven>

use Clone qw(clone);
use Data::Dumper;
use Getopt::Long;
use List::Util qw(shuffle);
use constant {ID =>0, POS =>1, NEIGHS => 2, SEEN=>3, NEXT => 4};
use warnings;
use strict;

my $usage= << "JUS";
  usage:   kshuffle.pl [OPTIONS]
  options: -k    select k-let to be preserved
           -n    number of sequences to be generated
           -v    verbosity
           -h    get this help
  example: kshuffle.pl -n 1 -k 2
           Waits for input on STDIN. If input is empty
           the default sequence AACGTAGCTAT is used.
  results: Shuffled sequence(s) with preserved k-let 
           counts of the input.
JUS


my $k=2;
my $N=1; # number of shuffled sequences;
my $verbose = 0;
my $help;

usage() unless GetOptions("k=i" => \$k,
			  "n=i" => \$N,
			  "v+"  => \$verbose, 
			  "h|help" => \$help);

if($help){
  print $usage;
  exit;
}
if($k<2){
  print STDERR "k has to be greater than 1!\n";
  exit;
}

my $seq = "";
while(<>){
  chomp $_;
  $seq .= $_;
  last if($_ eq "");
}
$seq = "AACGTAGCTAT" if($seq eq ""); # use default sequence
$Data::Dumper::Indent = 0;

print &kshuffle($seq), "\n" for (1..$N);

#######
# Shuffle the given sequence while preserving the k-let frequency. 
#
# The method is based on the method described in Jiang, Minghui, et
# al. "uShuffle: A useful tool for shuffling biological sequences
# while preserving k-let count".  2008. BMC Bioinformatics 9:192
#######

sub kshuffle {
  $seq  = shift;
  
  # build the multi-graph of (k-1)-lets. The Graph is stored in a
  # hash where keys are the (k-1)-lets, and values is a list
  # containing the index in the array, the position of its first
  # occurrence, the list of neighbors (outgoing edges) and the
  # default values for seen and next with 0 and undef, respectively.)
  
  print "Build multigraph for ", $seq, "\n" if($verbose);
  my $nid=0;
  my $plet = "";
  my %vert = (); # hash encoding the Graph
  my @vert;      # array mapping from IDs to hash entries
  for my $i (0..length($seq)-$k+1) {
    my $id;
    my $clet = substr($seq,$i,$k-1);
    
    if (!exists($vert{$clet})) {
      $vert[$nid] = $vert{$clet} = [$nid, $i, [], 0, undef];
      $id = $nid++;
    } else {
      $id = $vert{$clet}->[ID];
    }
    if ($i>0) {
      push @{$vert{$plet}->[NEIGHS]}, $id;
    }
    $plet = $clet;
  }

  print "Multigraph representation ", Dumper(%vert), "\n" if($verbose);

  # Generate an arborescence, i.e. a rooted tree in which all edges
  # point away from the root, via random walk that visits every
  # vertex. The root is the last possible k-let contained in the
  # input sequence. The arborescence contains for each vertex the
  # last outgoing edge used along the random walk (stored in NEXT).

  my $nlets =  @vert; 
  my $visited = 1;
  my $root = $vert{substr($seq, -($k-1))};
  $root->[SEEN]=1;
  
  for my $i (0..$nlets-1) {
    my $c = $i;
    print "Before updating seen and next starting walk at ", $i, " ",  Dumper(@vert), "\n" if($verbose);
    while (!$vert[$c]->[SEEN]) { # loop until a vertex that have been
				 # seen is reached by the walk
      print "looped\n" if($verbose);
      my $neighs = $vert[$c]->[NEIGHS];
      my $next = $neighs->[rand @$neighs];
      $vert[$c]->[NEXT] = $next;
      $c = $next;
    }
    $c = $i;
    while (!$vert[$c]->[SEEN]) { # set vertices of the walk to seen 1
      $vert[$c]->[SEEN]++;
      $c = $vert[$c]->[NEXT];
    }
    print "Updated seen and next starting walk at ", $i, " ",  Dumper(@vert), "\n\n" if($verbose);
  }

  # Generate Euler path from arborescence. For each vertex bring the
  # list of neighbors into a random order, except that the NEXT edge
  # is the last one.

  $root->[NEXT] = $root;

  foreach my $v (@vert) {

    my $neighs = $v->[NEIGHS];
    my $nn = @$neighs;
    my $next = $v->[NEXT];

    foreach $_ (@{$neighs}) { # swap the NEXT element into last position
      ($_, $neighs->[-1]) = ($neighs->[-1], $_) if $_ == $next;
    }
    # shufffle all except last element
    if ($v == $root) {
      @$neighs = shuffle @$neighs;
    } else {
      @$neighs[0..$nn-2] = shuffle @$neighs[0..$nn-2] if @$neighs>2;
    }
  }
  print "Shuffled neighboors: ", Dumper(@vert), "\n" if($verbose);
  


  # Finally just walk the graph following the edges in order

  my $rseq = substr($seq, 0, $k-1); # Initialize the shuffled sequence
				    # with the first possible k-let of
				    # the input sequence

  my $current = 0; # start vertex has ID 0
  my $walk = "";
  while (1) {
    $walk .= $current.">";
    $current = shift @{$vert[$current]->[NEIGHS]};
    last unless defined $current;
    $rseq .= substr($seq, $vert[$current]->[POS]+$k-2, 1);
  }
  print "Walked through: ", $walk, "\n" if($verbose);

  return $rseq;
}

__END__
