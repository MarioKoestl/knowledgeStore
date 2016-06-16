#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

use Bioinformatics::Pattern;
use Bioinformatics::Restriction;






my $usage= << "JUS";
  Title:    mkoestl_Ex05
  usage:    mkoestl_Ex05 -file [inputFile] 
  options: -file|f  [REQUIRED] [string]  : Input DNA sequence in fasta format
           -enzym|e  [OPTIONAL] [string] : Enzym cut pattern in regex format, default = "[ag]gatc[ct]"
           -circular|c [OPTIONAL] [string] : TRUE or FALSE if dna seq is circular, defualt = FALSE
           -help|h               print this message     

  results: calculate fragments sizes after restriction enzym has cutted given dna sequence
JUS

########c#########
my $opt_file;
my $opt_help;
my $opt_res="[ag]gatc[ct]";
my $opt_circ="FALSE";

GetOptions(
  "h|help|" => \$opt_help,
  "file|f=s" => \$opt_file,
  "enzym|e=s" => \$opt_res,
  "circular|c=s" => \$opt_circ);


#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (! -f $opt_file) {
    print "$opt_file is no valid file \n$usage";
    exit;
}

my $dna_seq = @{Bioinformatics::Pattern::getFastaSeqs($opt_file)}[0];
my @pos_Array = Bioinformatics::Pattern::getPatternMatchPositions(
                    "sequence"=> $dna_seq,
                    "pattern"=> $opt_res,
                    "is_circular"=>$opt_circ);

my @frags = Bioinformatics::Restriction::getFragmentLengths(
            "pos_array"=> \@pos_Array,
            "seq_Length"=>length($dna_seq),
            "is_circular"=>$opt_circ);

print "If sequence : \n\n $dna_seq \n\n with is_circular = $opt_circ is cutted with restriction enzym Pattern $opt_res, therefore following fragment lengths appear: \n\n"; 
foreach (@frags)
{
    print "$_\n";
}
########a#########
#my $dna_seq ="ccggatccggatccggcccggatcgcgcgcgcgcgcgcgcgcgggatcccgtagctacggatcc";

#my @pos = Bioinformatics::Pattern::getPatternMatchPositions(
#"sequence"=> $dna_seq,
#"pattern"=> "[ag]gatc[ct]",
#"is_circular"=>"TRUE");

#print "@pos \n\n";

########b#########
#my @frags = Bioinformatics::Restriction::getFragmentLengths(
#    "pos_array" => \@pos,
#    "seq_Length" => length($dna_seq),
#    "is_circular"=>"TRUE");

#print "@frags \n";





