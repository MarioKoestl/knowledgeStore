#!bin/usr/perl

use strict;
use warnings;
require mks_perl_tools;

use Getopt::Long;

my $usage= << "JUS";
  Title:    Exercise 4
  usage:   mkoestl_Ex04.pl -fileS [inputFileS] -fileR [inputFileR]
  
  options: -fileS|fs  [REQUIRED]   Input file for swissprot list file
           -fileR|fr  [REQUIRED]   Input file for Restriction enzym test
           -help|h               print this message
           -verbose|v            print additional informations
           
            results: See exercise 4 
JUS

my $opt_help;
my $opt_fileS;
my $opt_fileR;
my $opt_verbose;

GetOptions(
  "h|help|" => \$opt_help,
  "fileS|fs=s" => \$opt_fileS,
  "fileR|fr=s" => \$opt_fileR,
  "verbose|v" => \$opt_verbose);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (! -f $opt_fileS) {
    print "$opt_fileS is no valid file \n$usage";
    exit;
}
if (! -f $opt_fileR ){
    print "$opt_fileR is no valid file \n$usage";
    exit;
}

#1
print "\n##################\nNUMBER 1\n##################\n";
my @receptors = fileToArray($opt_fileS,"^ACM1_(HUMAN|MOUSE|RAT)"); # starting with ACM1_ and than either HUMAN or MOUSE or RAT

foreach (@receptors)
{
    print "$_\n";
}

#2
print "\n##################\nNUMBER 2\n##################\n";

my $seq = @{getFastaSeqs($opt_fileR)}[0];
my @cutArray = @{seq_cut($seq,"[A|G]GATC[T|C]")};

print "\nCut Sequence with length ",length($seq)," into Following pieces:\n";
foreach (@cutArray)
{
    print "Length = ",length($_),"\n";
}

#3

print "\n##################\nNUMBER 3\n##################\n";
my @ORFs = @{getORFs($seq)};

my $count=0;
foreach my $orf (@ORFs)
{
    print "ORF $count from: ", $orf->start," --> ",$orf->end," [len: ",$orf->len,"] \t",$orf->seq,"\n";
    $count+=1;
}
