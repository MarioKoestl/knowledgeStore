#!/usr/bin/perl

use strict;
use warnings;
use Class::Struct;

struct(Item=> {
   value  => '$',
   up => '$',
   left => '$',
   
});
use Getopt::Long;

my $usage= << "JUS";
  Title:    Manhatten Tourist Problem
  usage:   mtp_mkoestl_ex03.pl -file [inputFile]
  
  options: -file|f  [REQUIRED]   Input file for road matrix [int arrays]
                                 InutFile should have following format
                                 # west-east streets
                                 3 2 4 0
                                 3 2 4 2
                                 0 7 3 4
                                 3 3 0 2
                                 1 3 2 2
                                 
                                 # north-south streets 
                                 1 0 2 4 3
                                 4 6 5 2 1
                                 4 4 5 2 1
                                 5 6 8 5 3
           -help|h               print this message
           -verbose|v            print additional informations        

  results: Calculateds the path with the most costtourist attractions) from position (0/0) to most right and down corner of the road network. Dynamically Programmed
JUS



my $opt_help;
my $opt_file;
my $opt_verbose;

GetOptions(
  "h|help|" => \$opt_help,
  "file|f=s" => \$opt_file,
  "verbose|v" => \$opt_verbose);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (! -f $opt_file) {
    print "$opt_file is no valid file \n$usage";
    exit;
}

open(my $fh, "<", $opt_file) or die "Couldn't open '".$opt_file."' for reading because: ".$!;
my $z;
my @W;# =("3 3","3 2","0 7");
my @N;# = ("1 0 2","4 6 5");
while(my $line = <$fh>){
        chomp($line);
        print "$line\n";
        if ($line =~ /# west.+/) {
            $z="W";
            next;
        }
        elsif ($line =~ /# nort.+/) {
            $z="N";
            next;
        }
        elsif ($line =~ /\d/)
        {
         
         if($z eq "W")
         {
         #y @test= split(/ /,$line);
         #print "hugo @test\n\n";
          push(@W,[split(/ /,$line)]);
          
         }
         if($z eq "N")
         {
          push(@N,[split(/ /,$line)]);
         }
        }
        
}
my @S = [[]];

foreach ( @{$W[0]})
{
   print "$_  ";
}
print "\n";

foreach (@W)
{
   foreach my $i(@{$_})
   {
      print "$i\t";
   }
   print "\n";
}


initializeMatrix(\@W,\@N);



#starting filling all [j][0] and [0][i] and [0][0]

$S[0][0]->value(0); 

for(my $i = 1; $i< scalar @{$S[0]} ; $i++)
{
	$S[0][$i]->value($S[0][$i-1]->value + $S[0][$i]->left);
}

for(my $j = 1; $j< scalar @S; $j++)
{
	$S[$j][0]->value($S[$j-1][0]->value + $S[$j][0]->up);
}



# Starting with REAL problem solving
for(my $j = 1; $j< scalar @S; $j++)
{
	for(my $i = 1; $i< scalar @{$S[$j]} ; $i++)
	{
		$S[$j][$i]->value( max($S[$j-1][$i]->value + $S[$j][$i]->up, $S[$j][$i-1]->value + $S[$j][$i]->left)); # maxValue of this position can either be the maxValue on the left + the cost to get from left to cur Pos. or the maxValue above + the cost to get to the cur Pos.
	}
}


#startig with Backtracing

my $j = scalar(@S)-1;
my $i = scalar(@{$S[$j]})-1;
my @solution=();
my $s="";
push(@solution,"($j,$i)");
while ($i >0 and $j >0)
{
	if(($S[$j-1][$i]->value + $S[$j][$i]->up) == $S[$j][$i]->value)
	{
		$s=$j-1;
		push(@solution,"($s,$i)");
		$j=$j-1;
	}elsif($S[$j][$i-1]->value + $S[$j][$i]->left == $S[$j][$i]->value)
	{
		$s = $i-1;
		push(@solution,"($j,$s)");
		$i=$i-1;
	}
}
push(@solution,"(0,0)");


if ($opt_verbose) {
    printArray(\@S,"left");
    printArray(\@S,"up");
}


printArray(\@S,"value");
print "solutionPath= ";
foreach (reverse @solution)
{
   print "$_-->";
}





######################
###initializeMatrix###
### fills alls position of the matrix with structs, and therefore each posiion contains now the cost to get there from North or west direction
###arg1 [2D array with int values] : West-East costs
###arg2 [2D array with int values] : North-South costs
#######################

sub initializeMatrix
{   
   my @W = @{shift(@_)};
   my @N = @{shift(@_)};
   #print "W length= ",scalar(@W);
   
   #print "N length= ",scalar(@N);
   if($opt_verbose){print "Initializing West parameters......\n";}
   for(my $lineCount=0;$lineCount< scalar(@W);$lineCount++)
   {
       my @C = @{$W[$lineCount]};
       for(my $c =0; $c < scalar(@C)+1;$c++)
       {
           if($opt_verbose){print "modifying : S[$lineCount][$c] \n";}
           if ($c==0 and $lineCount==0) {
               my $it = Item->new();
               $it->left(-1);
               $it->up(-1);
               $S[$lineCount][$c]=$it;
           }elsif ($c==0) {
               my $it = Item->new();
               $it->left(-1);
               $S[$lineCount][$c]=$it;
           }elsif ($c>0) {
               my $it = Item->new();
               $it->left($C[$c-1]);
               $S[$lineCount][$c]=$it;
           }
           
        }
       print "\n";
   }
   if($opt_verbose){print "Initializing Nord parameters......\n";}
   my @C2 = @{$N[0]};
   for(my $c =0; $c < scalar(@C2);$c++)
   {
       $S[0][$c]->up(-1);
   }
   
   for(my $lineCount=0;$lineCount< scalar(@N);$lineCount++)
   {
       my @C = @{$N[$lineCount]};
       for(my $c =0; $c < scalar(@C);$c++)
       {
           if($opt_verbose){print "modifying : S[",$lineCount+1,"][$c] \n";}
           $S[$lineCount+1][$c]->up($C[$c]);    
        }
       print "\n";
       
   }
}
##############
####printArray
###printing the Matrix
###arg1 [2D array of structs]
###arg2 [string] what item of the struct to print
###############
sub printArray
{
    my @S = @{shift(@_)};
    my $what = shift(@_);
    ###Value
    print "$what\n\t";
    for (my $i=0; $i<scalar (@{$S[0]});$i++)
    {
        print "$i\t";
    }
    print "\n";
    
    for (my $j=0; $j<scalar (@S);$j++)
    {
        print "$j\t";
        foreach (@{$S[$j]})
        {
            my $item = $_;
            
            print $item->$what ."\t";
        }
        print "\n";
    }
}

sub max
{
	return ($_[0], $_[1])[$_[0] < $_[1]]
}

