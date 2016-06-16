#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $usage= << "JUS";
  
  usage:   vv_mKoestl.pl -file [FILE] -cutoff [max amount of money] -verbose
  
  options: -file|f    input text file [REQUIRED]
           -help|h    print this message
           -cutoff|c  amount of available money >=0 [REQUIRED] 
           -verbose|v print additional informations        

  results: Branch and bound algorithm for fiven input File and defined cutoff. returns all found solutions for given cutoff,
           verbose prints also all not used paths. RECURSIV algorithm
JUS



my $opt_help;
my $opt_cutoff=-1;
my $opt_file=0;
my $opt_verbose;

GetOptions(
  "h|help|" => \$opt_help,
  "file|f=s" => \$opt_file,
  "cutoff|c=i" => \$opt_cutoff,
  "verbose|v" => \$opt_verbose);
    
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
#check if cutoff was set to valid value
if ($opt_cutoff<0) {
    print "\n\nERROR..........\nCutoff has to be set and a positive value\n\n";
    print $usage;
    exit;
}





my %cityT = readInput($opt_file);
my @stack=();

#fill stack with all possible startTuple citys
# sort the hash by value in descending order, to get the lowest city pair at the end of the stack, and therefore start with the lowest one
foreach (sort { $cityT{$b} <=> $cityT{$a} } keys %cityT) 
{
    push(@stack,$_);
}

#print "@stack\n";


my $curPos="";
my $cost=0;
my %solution=();


tryRec(pop(@stack)); #first try would be the last city tuple from the stack

my $count_sol=1;
foreach (keys %solution)
{
    print "Solution $count_sol : ",getOutputString($_),"\nwith overall costs of $solution{$_}\n\n";
    $count_sol +=1;
}

if (!keys %solution){
    print"No solution found for given Cutoff of $opt_cutoff\n\n";
}

# recursivly going trough the stack and trying the city tuples
sub tryRec
{
  my $curPos = shift(@_);
  
  if (!$curPos) { # is the $curPos null, = stack is empty, = exit recursion
    return;
  }
  else
  {
    $cost=cost($curPos);
    if ($cost<=$opt_cutoff)
    {
        #print "A= $A\tCost= $cost\n";
        my @unusedCityT =  unusedCitys($curPos); # returna an array with all cityTuples not yet an use, at this position in the tree
        #print "unused\t@unusedCityT\n";
        if (scalar @unusedCityT == 0) { #if there is no more possibility to add another city tuple, than we are on the leaf, and we have a solution
            if ($opt_verbose) {
                print "Solution:",getOutputString($curPos),"\n was found with a overal cost of:\t$cost\n\n";
            }
            if (isNewSolution($curPos,\%solution)) {
              $solution{$curPos}=$cost;
            }
            
        }else{
            foreach (@unusedCityT) # add all other possibilitys to stack
            {
                push(@stack,$curPos.$_); # pushing the next solution sequence to stack
            }
        }  
    }else
    {
      if ($opt_verbose)
      {
        print "Possibility :",getOutputString($curPos),"\n will be pruned, because their overal cost of $cost exceeds the cutoff of $opt_cutoff\n\n";
      }
    }
    tryRec(pop(@stack)); # try the next citytuple on the stack, recursivly
  } 
}



sub getOutputString
{
  my $s = shift(@_);
  my $output="\t";
  
  foreach my $tuple (unpack("(A2)*",$s))
  {
    $output .= $tuple . "  ";
  }
  return $output;
  
}


sub readInput
{
    my $file =shift(@_);
    open(my $fh, "<", $file) || die "Couldn't open '".$file."' for reading because: ".$!;
    my @lines = <$fh>;
    
    
    
    my @citys = split(' ',$lines[1]);
    #print "@citys\n";
    #print scalar @citys;
    my %hash=();
    for(my $i=0;$i< scalar @citys;$i++)
    {
        for(my $j= ($i+1);$j< scalar @citys;$j++)
        {
            #print "$citys[$i]$citys[$j]\n";
            $hash{$citys[$i].$citys[$j]} = 0;
        }
    }
    
    
    
    my @curLine;
    for(my $i=2;$i<= scalar @citys;$i++)
    {
        @curLine = split(' ',$lines[$i]);
        for( my $j=$i-1;$j< scalar @curLine;$j++)
        {
            $hash{$citys[$i-2].$citys[$j]} = $curLine[$j];
        }
    }
    
    #print "$_ $hash{$_}\n" for (sort keys %hash);
    
    
    return %hash;
}
 
sub isNewSolution # check the difference between the new solution and solutions we already know
{
  my $newSol = shift(@_);
  my %sol = %{shift(@_)};
  
  if (keys %sol ==0) { ## first solution is a correct solution
    return 1;
  }
  
  my @newSol_a = unpack("(A2)*",$newSol);  # split the string into an array with 2 chars, i.e. a tuple
  #print "@newSol_a\n";
  foreach my $key (keys %sol)
  {
    my @sol_a = unpack("(A2)*",$key);
    my %diff;
    @diff {@newSol_a}=undef;
    delete @diff{@sol_a};
    if (keys %diff ==0) {
        return 0;
    }
  }
    
  return 1;
}  
   
#insert a list of city tuples, return a list with all tuples not already in use. 
sub unusedCitys
{
    my $rex = join '',@_;  #get a string for all parameters, further used as regex
    my @citys = keys %cityT;
    my @ret=();
    
    foreach my $cityT (@citys)
    {
        #print "City : $cityT\n";
        my @matches = $cityT =~ m/[$rex]/g; 
        #print "Matches: @matches\n";
        if (@matches == 0) { # regex was not found, which means no city of this CityTuplet was not already in use, therefore, use this tuple
           push(@ret,$cityT);
           #print "pushed $cityT to array\n";
        }
    }   
    return @ret;
}

#insert a string of cityTuples(without seperators) and calculate the actual cost if this tuples were used
sub cost
{
    my $cost=0;
    my $s = shift(@_);
    
    my @tuples = unpack("(A2)*",$s);  # split the string into an array with 2 chars, i.e. a tuple

    foreach my $cT (@tuples){ # iterate all cityTuples
        $cost+= $cityT{$cT};
    }
    return $cost;
}



