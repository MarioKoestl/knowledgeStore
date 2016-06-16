#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2008-05-28 13:52:27 ivo>
use Getopt::Long;
use strict;
srand();

my $w = 4;
my $h = 4;

GetOptions("w=i" =>\$w, "h=i" =>\$h);

print "# west-east streets\n";
for my $r (0..$h) {
  print join(" ", map {int(rand(10))} 1..$w), "\n";
}
print "\n";

print "# north-south streets\n";
for my $r (1..$h) {
  print join(" ", map {int(rand(10))} 0..$w), "\n";
}

