#!/usr/bin/perl -w
# last Time-stamp: <2007-01-01 23:18:49 at>
# date-o-birth: 2007-01-01 20:28:34 by at, Mexico City
# ancestor: one.pl, conv_seqs.pl

# ----------------------------------------------------------------------
# Perl Modules

use strict;
use Getopt::Long;
use SeqUtil qw(rev_complement
               toRNA
               toDNA);

# Some Variables
my @seq =();
my $fn;        # single seq. file name
my $sn;        # seq. name
my $len;       # length of sequence

# Command Line Options
my $revcomp;   # reverse cpmplement
my $one;       # print as oneliner
my $split;     # split multisequence file into single sequences
my $h;         # print usage
my $DNA;       # translate into DNA
my $RNA;       # translate into RNA
my $rev;       # reverse sequences
my $uc;        # sequence in upper case; default
my $lc;        # sequence in lower case
my $l;         # length of sequence

GetOptions ('revcomp' => \$revcomp,
	    'one'     => \$one,
	    'split'   => \$split,
	    'DNA'     => \$DNA,
	    'RNA'     => \$RNA,
	    'rev'     => \$rev,
	    'uc'      => \$uc,
	    'lc'      => \$lc,
	    'length'  => \$l,
	    'help|h'  => \$h);

# Print Usage
die "\nUsage: one.pl -one -split -revcomp seq.fa
-one       print sequence as one liner
-split     split multi fasta file into single sequence files
-revcomp   reverse complement of sequences
-rev       reverse sequences
-DNA       translate into DNA
-RNA       translate into RNA
-uc        sequence in upper case; default
-lc        sequence in lower case
-length    length of sequence
-h         this message\n
and now try again\n" if $h;

# Errors
die "you cannot run length in combination with other options!\n" if
($l && ($one || $revcomp || $rev || $DNA || $RNA || $uc || $lc || $split));

# ----------------------------------------------------------------------
# Famos!

while(<>){
    # Print sequence
    if ($seq[0] && /^>/){
      
      unless ($split || $l){
	foreach my $a (@seq){ $one ? print $a : print $a, "\n"; } 
	print "\n" if $one;
      }

      if ($split){
	open(OUT,">$fn") || die "couldn't open new file!\n";
	print OUT ">$sn\n";
	foreach my $a (@seq){ $one ? print OUT "$a" : print OUT "$a\n"; }
	print OUT "\n" if $one;;
	close(OUT);
      }

      @seq = ();

      print "$sn\t","$len\n" if $l; $len=undef;
    }

    # print seq name
    if (/^>.*/){
      $fn = "$1"."."."fa" if /^>\s?(\S+).*/; $fn =~ s/\|/\_/;
      $sn = $1 if /^>\s?(\S+).*/;
      print unless ($split || $l);
    }

    # get sequence and converte it
    if (/^\w+$/){
	chomp;
	$_ = uc(&rev_complement($_)) if $revcomp;
	$_ = uc(&toRNA($_)) if $RNA;
	$_ = uc(&toDNA($_)) if $DNA;
	$_ = reverse($_) if $rev;
	$_ = uc($_) if $uc;
	$_ = lc($_) if $lc;

	($rev || $revcomp) ? unshift(@seq,$_) : push(@seq,$_);
	
	$len += length($_) if $l;        # sequence length
    }

    # print seqence at EOF
    if ($seq[0] && eof()){
      
      unless ($split || $l){
	foreach my $a (@seq){ $one ? print $a : print $a, "\n"; }
 	print "\n" if $one;
      }
      
      if ($split){
	open(OUT,">$fn") || die "couldn't open new file!\n";
	print OUT ">$sn\n";
	foreach my $a (@seq){ $one ? print OUT "$a" : print OUT "$a\n"; }
	print OUT "\n" if $one;
	close(OUT);
      }
      
      @seq = ();
      
      print "$sn\t","$len\n" if $l; $len=undef;
    }
}

# end of file
