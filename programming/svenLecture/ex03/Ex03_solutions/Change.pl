#!/usr/bin/perl
# -*-Perl-*-
# Last changed Time-stamp: <2015-04-16 09:01:48 sven>
# $Id$

use Data::Dumper;
use Getopt::Long;
use POSIX;
use Pod::Usage;
use strict;
use vars qw/@C $M @bestNumberOfCoins $VERBOSE/;
use warnings;

# inizialize global(s)
@C = qw/1 2 5 10 20 50/;
$M = 99;
@bestNumberOfCoins = (0);
$VERBOSE = 0;

pod2usage(-verbose => 0)
    unless GetOptions(
      "N=f"  => \$M,
      "S=s"  => sub { @C = sort {$a<=>$b} split(':', $_[1]) },
      "help" => sub{ pod2usage(-verbose => 1) },
      "man"  => sub{ pod2usage(-verbose => 2) },
      "v"    => sub{ $VERBOSE++ }
    );

my $bnc = DP_change($M, @C);
print "Best number of coins is $bnc; amount $M, coins [@{[join(', ',@C)]}]\n";
print "Greedy change is ", join(', ', greedy(@C)), "\n";
print "Best change is   ", join(', ', backtrack(@C)), "\n";

#---
sub DP_change {
  my ($M, @c) = @_;

  for my $m (1..$M) {
    $bestNumberOfCoins[$m] = DBL_MAX; # DBL_MAX => double range = 1.79769313486232e+308
    for my $i (0..$#c) {

      if ($m >= $c[$i]) {

	if ($bestNumberOfCoins[$m-$c[$i]] + 1 < $bestNumberOfCoins[$m]) {
	  $bestNumberOfCoins[$m] = $bestNumberOfCoins[$m-$c[$i]] + 1;
	}
      }
    }
    print Dumper([@bestNumberOfCoins]), "\n" if $VERBOSE > 2;
  }

  return $bestNumberOfCoins[$M];
}

#---
# greedy solution.
sub greedy {
  my @c = @_;
  my @change = ();
  my $m = $M;

  while (@c) {
    pop(@c), next if $m < $c[-1];

    if ($m - $c[-1] >= 0) {
      push @change, $c[-1];
      $m -= $c[-1];
    }
    else { pop(@c) }
  }

  push @change, "[FAILURE with rest of $m]" if $m>0;

  return @change;
}

#---
# bachtracks optimal solution
sub backtrack {
  my @c = @_;
  my @change = ();
  my $m = $M;

  while ($m>0) {
    my $numcoins = $bestNumberOfCoins[$m];
    foreach my $c (reverse @c) {
      next if $c>$m;
      if ($bestNumberOfCoins[$m-$c] + 1 == $numcoins) {
	push @change, $c;
	$m -= $c;
	last;
      }
    }
  }
  return @change;
}

=pod

=head1 NAME

Change.pl - solves the coin change problem

=head1 SYNOPSIS

Change.pl [ [-N I<FLOAT>] [-S I<STRING>] [-help] [-man] [-v]]

=head1 OPTIONS

=over 4

=item B<-N> I<INT>

Set amount of change to I<INT>; e.g. 99

=item B<-S> I<STRING>

Set denomination of coins to I<STRING>; I<STRING> is colon seperated
e.g. 1:2:5:10:20:50

=item B<-help>

Show synopsis.

=item B<-man>

Show man page.

=item B<-v>

Increase verbosity level.

=back

=head1 DESCRIPTION

Given an integer N and a set of integers S = {s_1, s_2, ..., s_m}. The
integer partitioning problem asks to express N as a linear combination
of S[1..m] with non-negative coefficients, e.g.

 N = 4 can be partitioned with S = {1, 2, 3} into the following linear
 combinations:

 lc_1 = 4 x 1 + 0 x 2 + 0 x 3     {1, 1, 1, 1}
 lc_2 = 2 x 1 + 1 x 2 + 0 x 3     {1, 1, 2}
 lc_3 = 0 x 1 + 2 x 2 + 0 x 3     {2, 2}
 lc_4 = 1 x 1 + 0 x 2 + 1 x 3     {1, 3}

The coin change problem now projects the integer partitioning problem
into the realm of money. It asks for the minimum number of coins given
(as change) to a customer, in other words the coin change problem asks
for the linear combination where a maximum number of coefficients is
set to 0. Note that the solution can be degenerated and that for
certain denominations of coins a greedy strategy will always give the
optimal result. (Pathological cases: Greedy does not succeed for N = 10,
S = {1, 5, 7} and fails for the McNugget case N = 99, S = {6, 9, 20})

Change.pl solves the coin change problem exact with dynamic
programming and with the well known greedy strategy used by sales
clerks.

=head1 AUTHORS

Ivo Hofacker, Christoph Flamm

=cut

__END__
