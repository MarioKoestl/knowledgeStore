#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2003-01-05 11:24:32 ivo>
# Print the consensus sequence for part of an Clustalw alignment and the
# corresponding piece of  structure in bracket notation (from the second file).
# Print to STDERR the length, number of conserved positions, and mean 
# pairwise homology.
# Since alidot output contains the "believable" structure use e.g. as
# consens.pl -f 7401 -l 7800 HIV.aln HIVali.out
# if -a option is given print all sequences plus their consensus

use strict;

sub usage {
    die "Usage: $0 [-a] [-f from] [-l last] [--aln] clustalw.aln [alidot.out]\n";
}
my %seq;
my $from=1; my $to=99999; my ($p_all, $p_aln);
while ($_ = shift(@ARGV)) {
    /^-[\?h]/ && usage();  # filenames starting with -h not allowed :(
    /^-f$/ && ($from = shift(@ARGV), next );
    /^-l$/ && ($to   = shift(@ARGV), next );
    /^-a$/ && ($p_all =1, next);
    /^--aln$/ &&  ($p_aln =1, next);
    unshift (@ARGV, $_);
    last;
}

$_ = shift @ARGV; open(ALN,"<$_") || die("can't open alignment");
die ("$_ is not a Clustal W alignment") unless (<ALN> =~ /^CLUSTAL/);

my ($cseq, $conserved, $meandist, $lcons, $lmean) = consensus($from, $to);
my $alen = length($cseq);
printf STDERR
    "length of alignment: %d, conserved %d, mean pairwise homology %4.1f\n",
    $alen, $conserved, 100*($alen-$meandist)/$alen;
if ($from!=1 || $to!=99999) {
    printf STDERR
    "local values from %d to %d: conserved %d, mean homology %4.1f\n",
    $from, $to, $lcons, 100*(($to-$from+1)-$lmean)/($to-$from+1);
}
if ($p_all) {
    foreach my $n (keys %seq) {
	print "> $n\n", substr($seq{$n},$from-1, $to-$from+1), "\n";
    }
}
if ($p_aln) {
    print "CLUSTAL W(1.81) multiple sequence alignment\n\n\n";
    foreach my $n (keys %seq) {
	printf "%-10s     %s\n", $n, substr($seq{$n},$from-1, $to-$from+1);
    }
    print "                              \n";
} else {
    print "> $from", "_$to\n", substr($cseq, $from-1, $to-$from+1), "\n";
}

if ($#ARGV==-1) { ; }
else {
    while (<>) {    
	next unless (/\.\.\./);           # find the dot bracket structure
	# print substr($_, $from-1, $to-$from+1), "\n";
	my $struct = &fix_structure(substr($_, $from-1, $to-$from+1));
	print "$struct\n"; # print substructure
    }
}
sub consensus {
    my($cseq, $i, $s, $c);
    my($first, $last) = @_;

    while (<ALN>) {
	next unless (/^\S+\s+\S+/); # look only at lines containing sequences
	chomp;
	my($name, $sseq) = split;
	$seq{$name} .= $sseq;        # collect sequences
    }
    my $l=length($seq{(keys %seq)[0]});
    foreach $s (keys %seq) {
	die("unequal lengths in alignment") if (length($seq{$s})!=$l);
    }
    my $n = (keys %seq); # number of sequences
    my($meandist, $conserved) = (0,0); # mean pairwise distance
    my($locmeandist, $locconserved) = (0,0);
    for ($i=0; $i<$l; $i++) {     # foreach position in sequence ...
	my %char=();
	foreach $s (keys %seq) {  # ... get character frequencies ...
	    $char{substr($seq{$s},$i,1)}++;
	}
	my @sorted = sort {$char{$b} <=> $char{$a}} keys %char; 
	$cseq .= $sorted[0];      # .. and take the most frequence char

	# now get the mean distance at this position
	my $d=0;

	foreach $c (keys %char) {
	    $d += $char{$c}*($n - $char{$c});
	}
        my $tmp = $d/($n*($n-1));
	$meandist += $tmp;

	$conserved++ if ($d==0);  # conserved position

        if (($i >= $first-1) && ($i < $last)) { 
	    $locmeandist += $tmp;
	    $locconserved++ if ($d==0);
	}
    }

    $to = $l if ($to>$l);         # change $to if too large
    return ($cseq, $conserved, $meandist, $locconserved, $locmeandist);
}

sub fix_structure {   # remove non-matching brackets 
    #indices start at 0 in this version!
    my($i,$j,$c,$hx, @olist);
    my($structure) = pop(@_);
    
    $hx=$i=0;
    
    foreach $c (split(//,$structure)) {
	if ($c eq '(') {
            $olist[++$hx]=$i;
        } elsif ($c eq ')') {
	    if ($hx>0) {$hx--;}
	    else {
		substr($structure, $i, 1) = '.';
	    }
        }
        $i++;
    }
    while ($hx>0) {
	$i = $olist[$hx--];
	substr($structure, $i, 1) = '.';
    }
    die ("couldn't fix structure $structure $hx") if ($hx!=0);
    return $structure;
}
