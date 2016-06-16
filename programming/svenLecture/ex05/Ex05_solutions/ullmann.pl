#!/usr/bin/perl
# -*-Perl-*-
# Last changed Time-stamp: <2008-06-26 00:05:06 xtof>
# $Id$
#
# Literature:
# Ullmann, JR "An Algorithm for Subgraph Isomorphism".
# Journal of the Association for Computing Machinery, Vol 23, No.1,
# January 1976, pp 31-42.
#

use strict;
use vars qw/@FFF $S1 $S2/;

$S1 = read_molecule();
$S2 = read_molecule();
ullmann($S1, $S2);
dump_subgraph_isomorphisms();

#---
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

#---
sub parse_vertices {
  local $_;
  my $M = shift();
  my $num_v = $1 if ($_=<>) =~ m/^(\d+)$/;
  my $v = $num_v;
  do {
    $M->{$1} = [$2,[((0) x $v)],'-'] if ($_=<>) =~ m/^(\d+)\s+(\w+)$/;
  } while --$num_v > 0;
}

#---
sub parse_edges {
  local $_;
  my $M = shift;
  my $num_e = $1 if ($_=<>) =~ m/(\d+)/;
  do {
    $M->{$1}[1][$2] = 1, $M->{$2}[1][$1] = 1
	if ($_ = <>) =~ m/(\d+)\s+(\d+)\s+(\S+)/;
    $M->{$1}[2] = $3;
  } while --$num_e > 0;  
}

#---
sub ullmann {
  my ($S1, $S2) = @_;

  # make smale molecule the query graph
  ($S1, $S2) = ($S2, $S1) if keys %$S1 > keys %$S2;
  my @F = ();
  my $M0 = build_M_0($S1, $S2);

  # print input
  dump_adj_matrix($S1, "S1");
  dump_adj_matrix($S2, "S2");
  dump_lol("M0", $M0);
  
  my $rows = scalar(keys %$S1);
  my $cols = scalar(keys %$S2);
  my $depth = 0;

  backtrack_all($S1, $S2, $depth, $M0, $rows, $cols);
}

#---
sub backtrack_all {
  my ($g1, $g2, $depth, $M, $rows, $cols) = @_;

  my @FF = ();
  
  for(my $i=0; $i<$cols; $i++) {

    if ($M->[$depth][$i] == 1) {
      my @F = ();
      push @F, [$depth, $i];
      my $M1 = deep_copy_lol($M);
      for (my $m=$depth+1; $m<$rows; $m++) { $M1->[$m][$i] = 0 }

      if (forward_checking($g1, $g2, $M1, $depth, \@F, $rows, $cols)) {
	if (backtrack($g1, $g2, $depth+1, $M1, \@F, $rows, $cols) == 1) {
	  next;
	}
      }
      @F = grep {($_->[0] != $depth) || $_->[1] != $i} @F;
    }
  }

  return \@FF;
}

#---
sub backtrack {
  my ($g1, $g2, $depth, $M, $F, $rows, $cols) = @_;

  # we hit the bottom

  do { # memorize subgraph isomorphism
    push @FFF,deep_copy_lol($F);
    return 1 } if $depth == $rows;
  
  for (my $i=0; $i<$cols; $i++) {

    if ($M->[$depth][$i] == 1) {
      push @$F, [$depth, $i];
      my $M1 = deep_copy_lol($M);

      for (my $m=$depth+1; $m<$rows; $m++) { $M1->[$m][$i] = 0 }

      if (forward_checking($g1, $g2, $M1, $depth, $F, $rows, $cols)) {
	backtrack($g1, $g2, $depth+1, $M1, $F, $rows, $cols);
      }

      @$F = grep {($_->[0] != $depth) || ($_->[1] != $i)} @$F;
    }
  }
}

#---
sub forward_checking {
  my ($g1, $g2, $M, $depth, $F, $rows, $cols) = @_;

  for (my $k=$depth+1; $k<$rows; $k++) {
    for (my $l=0; $l<$cols; $l++) {

      if ($M->[$k][$l] == 1) {
	foreach my $f (@$F) {
	  my $bond_in_g1 = $g1->{$k}->[1][$f->[0]];
	  my $bond_in_g2 = $g2->{$l}->[1][$f->[1]];

	  # in g1 and g2 a bond (keep 1)
	  if (($bond_in_g1 == 1) && ($bond_in_g2 == 1)) {
	    $M->[$k][$l] = 1;
	    next;
	  }

	  # neither in g1 nor in g2 a bond (keep 1)
	  if (($bond_in_g1 == 0) && ($bond_in_g2 == 0)) {
	    $M->[$k][$l] = 1;
	    next;
	  }

	  # only in g1 or g2 a bond (flip 1 to 0)
	  $M->[$k][$l] = 0;
	}
      }
    }
  }

  # check if we created a all-zero's row
  my $zero_row = 0;
  for (my $k=0; $k<$rows; $k++) {
    for (my $l=0; $l<$cols; $l++) {
      if ($M->[$k][$l] == 1) { last }
      else { $zero_row++ }
    }

    # bad matrix found all-zero's row
    if ($zero_row == $cols) {
      return 0;
    }
    
    $zero_row = 0;
  }

  # good matrix no all-zero's row
  return 1;
}

#---
sub dump_subgraph_isomorphisms {

  print "found ", scalar(@FFF), " subgraph isomorphism(s).\n";
  foreach my $morph (@FFF) {
    my @m = map{ $_->[1]} sort {$a->[0]<=>$b->[0]} @$morph;
    print "[", join(", ", @m), "]\n";
  }
}

#---
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

#---
sub degree { scalar grep {$_ == 1} @{shift()} }

#---
sub deep_copy_lol { my @m=(); push @m, [@$_] foreach @{shift()}; \@m }

#---
sub dump_lol {
  print shift(), "\n";
  print join(" ", @$_), "\n" for @{shift()};
  print "\n";
}

#---
sub dump_adj_matrix {
  my ($s, $name) = @_;
  my @s = ();
  push @s, $s->{$_}[1] for sort {$a<=>$b} keys %$s;
  dump_lol($name, \@s);
}

__END__
