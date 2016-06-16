#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

use Text::Soundex;


my $usage= << "JUS";
  Title:    mkoestl_Ex05
  usage:    mkoestl_Ex05 -w[word1] -w2[word2] 
  options:  -w [string] : first word to compare pronounciations
            -w2 [string] : second word to compare pronounciations
            -help|h               print this message     

  results: Returns if these two english words are pronounced exactly the same
JUS

my $opt_help;
my $opt_w;
my $opt_w2;

GetOptions(
  "h|help|" => \$opt_help,
   "w=s"=> \$opt_w,
   "w2=s"=> \$opt_w2,
   );

#print usage if requested
if($opt_help){
  print $usage;
  exit;
}
if (!$opt_w or !$opt_w2) {
    print "You have to insert two correct english words \n$usage";
    exit;
}

if (soundex($opt_w) eq soundex($opt_w2)) {
    print ("$opt_w and $opt_w2 are pronounced exactly the same\n");
}else{
    print ("$opt_w and $opt_w2 are NOT pronounced exactly the same\n");
    
}
