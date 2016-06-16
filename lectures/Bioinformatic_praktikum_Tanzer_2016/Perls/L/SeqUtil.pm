package SeqUtil;

# Last Time-stamp: <2014-06-20 14:19:57 at>

# Standard Perl modules
use strict;
use warnings;
#use Carp;
#use Useful;
#use Genome;

my $debug;

# Extra packages
require Exporter;
#use Exporter;
#our($VERSION, $PACKAGE, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

#$VERSION = 0.01;
our @ISA = qw(Exporter);
our @EXPORT_OK = ();

our @EXPORT = qw(get_baseprobability
	     get_basefrequency
	     makeRandomBase
	     get_minmax_basefreqency
	     get_subsequence
	     GC_content
	     toRNA
	     toDNA
	     rev_complement
	     onelinealn
	     codonPos
	     DNAtoProt
	     RevTrans
);

#	     revtrans_aln
sub get_baseprobability{
    my ($seq) = @_;
    my %seen = ();
    
    my $seqLength = length($seq);
    print "no of bases: $seqLength\n" if $debug;
    
    foreach my $base (split "", $seq) {
	$seen{$base}++;
    }
    
    print %seen, "\n" if $debug;
    
    my $probA = ($seen{a}/$seqLength);
    my $probC = ($seen{a}+$seen{c})/$seqLength;
    my $probG = ($seen{a}+$seen{c}+$seen{g})/$seqLength;
    my $probU = 1 - $probG;
    
    return($probA, $probC, $probG, $probU);
}

sub get_basefrequency{
    my ($seq) = @_;
    my %seen = ();

    $seq = lc($seq);
    my $seqLength = length($seq);
    print "no of bases: $seqLength\n" if $debug;
    
    foreach my $base (split "", $seq) {
	$seen{$base}++;
    }
    
    print %seen, "\n" if $debug;

    foreach my $base (keys (%seen)) {
	$seen{$base} = $seen{$base}/$seqLength;
    }
    
    return(%seen);
}

# This is a subroutine that generates one random DNA letter.  You can
# use it as shown above.  You should not need to modify anything below
# this line.
sub makeRandomBase {
  my ($numSeqs,
      $seqLength,
      $probA,
      $probC,
      $probG) = @_;
  my $prob;
  my @returnValues;
  
  my $seqcount = 0;

  print "subroutine generating $numSeqs sequences of length $seqLength\n" if $debug;
  print "base frequencies A\:$probA, C: $probC, G: $probG\n" if $debug;

  while ($seqcount < $numSeqs){
      my $returnValue ="";
      my $basecount = 0;
      my $a = 0;
      my $c = 0;
      my $g = 0;
      my $t = 0;
      while ($basecount < $seqLength) {
	  $prob = rand;
	  if ($prob < $probA) {
	      $returnValue = 'A';
	      $a++;
	  } elsif ($prob < $probC) {
	      $returnValue = 'C';
	      $c++;
	  } elsif ($prob < $probG) {
	      $returnValue = 'G';
	      $g++;
	  } else {
	      $returnValue = 'T';
	  $t++;
	  }
	  #print "$returnValue\n";
	  $returnValues[$seqcount].= $returnValue;
	  $basecount++;
      }
      #print $returnValues[$seqcount],
      print "\nA: ", $a/$seqLength,
      " C: ", ($a+$c)/$seqLength,
      " G: ", ($a+$c+$g)/$seqLength,
      " T: ", ($a+$c+$g+$t)/$seqLength, "\n" if $debug;
      $seqcount++;
      print "seqcount $seqcount\n" if $debug;
  }
  return(@returnValues);
}

sub get_minmax_basefreqency {
    my ($bases_href,
	$minbases_href,
	$maxbases_href) = @_;
    
    my %minbases = %$minbases_href;
    my %maxbases = %$maxbases_href;
    my %bases = %$bases_href;
    
    foreach my $base (keys (%minbases)) {
	($minbases{$base} = $bases{$base}) if ($minbases{$base} > $bases{$base});
    }
    foreach my $base (keys (%maxbases)) {
	($maxbases{$base} = $bases{$base}) if ($maxbases{$base} < $bases{$base});
    }
    return(\%minbases,\%maxbases);
}
# End of package SeqUtil

sub get_subsequence {
    my ($seq,
	$start,
	$length) = @_;
    
    my $subseq = substr($seq,($start-1),$length);
    return $subseq;
}

sub GC_content {
    my ($bases_href) = @_;

    my %bases = %$bases_href;
    my $GC_current = sprintf("%.2f", ($bases{c} + $bases{g}));
    return $GC_current;
}

sub toRNA {
    my ($DNAseq) = @_;
    
    my $RNAseq = lc($DNAseq);
    $RNAseq =~ s/t/u/g;
    return $RNAseq;
}

sub toDNA {
    my ($RNAseq) = @_;
    
    my $DNAseq = lc($RNAseq);
    $DNAseq =~ s/u/t/g;
    return $DNAseq;
}
sub rev_complement {
    my ($seq) = @_;  ## the DNA string to be transcribed
    my $compl = scalar reverse lc($seq);
    $compl =~ tr/acgt/tgca/ if $compl =~ m/t/g;
    $compl =~ tr/acgu/ugca/ if $compl =~ m/u/g;
    return $compl;
}


sub onelinealn{
    my ($file) = @_;
#    print "fh $file\n";
    open(ALN, "$file") || die "could not open aln file $!\n";
    my %seqs = ();
    while (<ALN>){
	next if /^CLUSTAL W.*/;
	next if m/\*/;
	next if m/^\n/;
	next if m/^\s/;
	chomp;
	my @in = ();
	push(@in,split(' ',$_));
#       print "IN: @in\n";
	if (exists($seqs{$in[0]})){
	    $seqs{$in[0]} .= $in[1];
#	    print "exists: $seqs{$in[0]}\n";
	}
	else {
	    $seqs{$in[0]} = $in[1];
	}
#       print "CURRENT STATE: $seqs{$in[0]}\n";
    }
    close(ALN);
    return \%seqs;
}

sub codonPos {
    my ($aln, $pos) = @_;
    my $pic;   # position in codon
    my $s = $$aln[0]->{start};
    
    $pic = ($s + $pos)%3;
    $pic += 3 unless $pic;

    my $codon = &sliceAlnByColumn($aln,$pos-$pic+1,$pos-$pic+1+3);

    my @cc = ();
    push @cc, $_->{seq} foreach @$codon;
    
    return $pic, @cc;
}

sub DNAtoProt {

    my ($in) = @_;
    my @trans;
    my %translate=('TTT'=>'F','TTC'=>'F','TTA'=>'L','TTG'=>'L',
		   'TCT'=>'S','TCC'=>'S','TCA'=>'S','TCG'=>'S',
		   'TAT'=>'Y','TAC'=>'Y','TAA'=>'*','TAG'=>'*',
		   'TGT'=>'C','TGC'=>'C','TGA'=>'*','TGG'=>'W',
		   'CTT'=>'L','CTC'=>'L','CTA'=>'L','CTG'=>'L',
		   'CCT'=>'P','CCC'=>'P','CCA'=>'P','CCG'=>'P',
		   'CAT'=>'H','CAC'=>'H','CAA'=>'Q','CAG'=>'Q',
		   'CGT'=>'R','CGC'=>'R','CGA'=>'R','CGG'=>'R',
		   'ATT'=>'I','ATC'=>'I','ATA'=>'I','ATG'=>'M',
		   'ACT'=>'T','ACC'=>'T','ACA'=>'T','ACG'=>'T',
		   'AAT'=>'N','AAC'=>'N','AAA'=>'K','AAG'=>'K',
		   'AGT'=>'S','AGC'=>'S','AGA'=>'R','AGG'=>'R',
		   'GTT'=>'V','GTC'=>'V','GTA'=>'V','GTG'=>'V',
		   'GCT'=>'A','GCC'=>'A','GCA'=>'A','GCG'=>'A',
		   'GAT'=>'D','GAC'=>'D','GAA'=>'E','GAG'=>'E',
		   'GGT'=>'G','GGC'=>'G','GGA'=>'G','GGG'=>'G');

    foreach my $i (@$in){
	exists($translate{$i}) ? push @trans, $translate{$i} : push @trans, 'X';
    }
    return \@trans;
}

#sub trans_revtr {
#    my ($fa) = @_;
#    my ($tmp, $tmp_fh) = &tmp_file();
#    
#    `trans_revtr $fa > $tmp`;
#    return ($tmp, $tmp_fh);
#}
#
#sub revtrans_aln {
#    my ($fa) = @_;
#    my ($aa, $aa_fh) = &trans_revtr($fa);
#    `clustalw $aa`;
#    `revtrans $fa $aa.aln -O aln > $fa.aln`;
#    return($aa);
#}
1;

