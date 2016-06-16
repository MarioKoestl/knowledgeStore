#!/usr/bin/perl -w
# -*-Perl-*-
# Last changed Time-stamp: <2016-03-15 13:04:49 sven>
# $Id$


use Getopt::Long;

#adapt to each program
my $usage= << "JUS";
  
  usage:   wordcount_sven.pl -file [FILE]
  
  options: -file    input text file [REQUIRED]
           -help    print this message
           -hyp     turn on hyphination, i.e. takes care that 
                    a wo-\\nrd is counted as word
           -eng     parse text as english and convert he\'s 
                    to he is
           -ger      parse text as german i.e. check for umlaute

  results: The script prints to stdout all words
           found in the text in descending order of
           their frequency. All stuff that could not be parsed 
           is printed to STDERR.
JUS

#adapt to used variable(s)
use strict;
#version 1 global variable(s)
use vars qw/%WC $opt_file $opt_help $opt_hyp $opt_eng $opt_ger/;
#version 2 local (only in the programm known) variable(s)
#my (...);
#a=s a must be String
#b=i b must be Integer
#d   d = 1 =>  if 'd' is defined, esle d = undef 
usage() unless GetOptions(
  "d|help|h" => \$opt_help,
  "file|f=s" => \$opt_file,
  "hyphenation|hyp" => \$opt_hyp,
  "german|g|ger" => \$opt_ger,
  "english|e|eng" => \$opt_eng);

#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

#check if the file exists
unless(-e $opt_file){
  print $usage;
  exit;
}

open(FI, $opt_file) or die "Can't open ",$opt_file,"\n";
my $mem = ""; #used to store beginning of a word if hyphenation is turned on

# necessary if we have umlauts in a german text
my %UMLAUTE = ( 
    'Ä' => 'Ae',
    'Ö' => 'Oe', 
    'Ü' => 'Ue',
    'ä' => 'ae',
    'ö' => 'oe', 
    'ü' => 'ue', 
    'ß' => 'ss',
    'é' => 'e' 
    );
my $UMLKEYS = join("|", keys(%UMLAUTE)); #create the regular expression part of all umlaut keys


while(<FI>){
  $_ =~ s/^\s+|\s+$//g; #remove leading and trailing white spaces
  tr/A-Z/a-z/; #convert everything to lower case
  my @tmp = split(/\-\-|\s+/, $_); #split at dashes (--) and at a arbitrary number of whitespaces
  for(my $i=0; $i<@tmp; $i++){
    my $word = $tmp[$i];
    $word = $mem.$tmp[$i] if($mem and $i == 0); #only needed if hyphenation is turned on
    $word =~ s/^[\W\d]*//gi; #remove leading non alphabetical symbols
    $mem = substr($word,0,length($word)-1) if(($i == scalar(@tmp)-1) and $word =~ /.*\-$/ and $opt_hyp); #store begining of splited word if hyphenation is turned on
    $word =~ s/[\W\d]*$//gi; #remove trailing non alphabetical symbols
    if($word eq ""){
      print STDERR "Could not handle word >$tmp[$i]< as it get's empty after removal of non alphabetical symbols\n";
      next;
    }
    
    if($opt_eng){
      #convert the english abbrevations into two words, e.g. he's into he is
      if($word =~ /([a-z]+)'([a-z]+)/){
	if($2 eq "s"){
	  $WC{"is"}++;
	  $word = $1;
	}
	elsif($2 eq "t"){
	  $WC{"not"}++;
	  $word = substr($1, 0, length($1)-1);
	  if($word eq "wo"){
	    $word = "would";
	  }
	}
	elsif($2 eq "ll"){
	  $WC{"will"}++;
	  $word = $1;
	}
	elsif($2 eq "re"){
	  $WC{"are"}++;
	  $word = $1;
	}
	elsif($2 eq "ve"){
	  $WC{"have"}++;
	  $word = $1;
	}
	elsif($2 eq "d"){
	  $WC{"had"}++;
	  $word = $1;
	}
	elsif($2 eq "m"){
	  $WC{"am"}++;
	  $word = $1;
	}
	elsif($word eq "o'clock"){
	  $WC{$word}++;
	  next
	}
	else{
	  print STDERR "Could not handle word >$word< containing ' in english mode.\n";
	  next;
	}
      }
      #convert i.e.
      elsif($word eq "i.e"){
	$WC{"that"}++;
	$WC{"is"}++;
	next;
      }
      #convert e.g.
      elsif($word eq "e.g"){
	$WC{"for"}++;
	$WC{"example"}++;
	next;
      }
    }
    if($opt_ger){
      #convert umlaute
      $word =~ s/($UMLKEYS)/$UMLAUTE{$1}/g;
    }
        
    #take care of compound-noun
    if($word =~ /[a-z]+\-[a-z]+/){
      $WC{$word}++;
      next;
    }
    #report and skip strange words
    elsif($word =~ /[\W\d]/){
      print STDERR "Word >$word< not counted due to strange symboles.\n"; 
      next;
    }
    $WC{$word}++;
  }
}
close(FI);

# sort hash keys by frequency and alphabetically and output key-value pairs
foreach my $word (sort {$WC{$b} <=> $WC{$a} || $a cmp $b } keys %WC){
  printf "%2d %s\n", $WC{$word}, $word;
}


__END__
