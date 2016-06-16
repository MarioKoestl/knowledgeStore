#!/usr/bin/perl

use lib "/home/mescalin/mario/svenUebung/270056/Ex05/mKoestl/modules/Graph_modules/"; # yust for testing with me, no idea how to make it independend
use lib "/home/mescalin/mario/svenUebung/270056/Ex05/mKoestl/modules/Math-Matrix-0.8";



use strict;
use warnings;
use Graph;
use Matrix;

use Data::Dumper;


use Getopt::Long;

my $usage= << "JUS";
  Title:   graph_isomorphism_mkoestl.pl
  usage:   perl -I modules/Graph_modules -I modules/Math-Matrix-0.8 graph_isomorphism_mkoestl.pl -target [file] -query [file]
  
  options: -target|t  [REQUIRED]    path to file describing the target graph
           -query|q   [REQUIRED]    path to file describing the query graph
           -help|h               print this message
           -verbose|v            print additional informations        
        
  results: checks if graph query is a sugraph isomorph of graph target, if yes prints all the possibilities on the screen
JUS



my $opt_help;
my $opt_v;
my $f_query;
my $f_target;

GetOptions(
  "h|help|" => \$opt_help,
  "query|q=s" => \$f_query,
  "target|t=s" => \$f_target,
  "verbose|v" => \$opt_v);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}
if (!$f_query or !$f_target) {
    print $usage;
    exit;
}





my $graph_target = new Graph("target");
initializeGraph($graph_target,$f_target);
my $graph_query = new Graph("query");
initializeGraph($graph_query,$f_query);

my $query_m = new Math::Matrix(@{$graph_query->adjMatrix()});
my $target_m = new Math::Matrix(@{$graph_target->adjMatrix()});

print "\ntarget-Adjecency Matrix\n";
printMatrix($query_m);
print "\nquery-Adjecency Matrix\n";
printMatrix($target_m);


#create the n X m matrix, already prune some things, more details in function 'isMatchPossible'
my @matrix = [[]];
my @verticesQ = @{$graph_query->vertices()};
my @verticesT = @{$graph_target->vertices()};
for(my $n = 0;$n < scalar(@verticesQ);$n++)
{
    for(my $m = 0;$m < scalar(@verticesT);$m++)
    {
        $matrix[$n][$m] = isMatchPossible($verticesQ[$n],$verticesT[$m]); # check for the vertix pairs, if it is possible to match
    }
}


if ($opt_v)
{
    print("Matrix before Pruning :\n");
    printMatrix(\@matrix);
}

@matrix = @{pruneMatrix(\@matrix,$target_m,$query_m)}; # now also checks if the neighbours are correct, i.e. the ullmann algorithm stuff

if ($opt_v)
{
    print("Matrix after Pruning :\n");
    printMatrix(\@matrix);
}


my $M = new Math::Matrix(@matrix);

# now start with the finding of all correct embeddings
my %usedColumns;
my $curRow =0;
my @embeddings; # @embeddings will be filled within the recursion function enumEmbed and contains every possible embedding
my @solutions;

enumEmbed(\%usedColumns,$curRow,\@matrix);

foreach (@embeddings)
{
    my $M = new Math::Matrix(@{$_});
    my $C = $M->multiply($target_m);
    $C = $C->transpose();
    $C =  $M->multiply($C);
    if ($query_m->equal($C)) {
        push(@solutions,$M);
    }
}
if (scalar @solutions == 0) {
    print " No subgraph Isomorphs were found\n";
}else
{
    my $counter=1;
    foreach (@solutions)
    {
        my @sol_matrix = @{$_};
        print "\n $counter. Solution: \n";
        if ($opt_v) {
            printMatrix(\@sol_matrix);
        }
        
        print "QId : QLabel -> TId : TLabel\n";
        for(my $row = 0;$row < scalar(@sol_matrix);$row++)
        {
            my $vertexQ = $graph_query->getVertixById($row);
            my $col = @{get1Columns(\@sol_matrix,$row)}[0]; # get the first element, should be only one element, elsewise everything is completely wrong
            my $vertexT = $graph_target->getVertixById($col); 
            print $vertexQ->id,": ",$vertexQ->label," -> ",$vertexT->id,": ",$vertexT->label,"\n";
        }
        $counter++;
    }
}

############################
#isMatchPossible
# checks if the given two vertices can be matched given following rules:
# 1-> both vertices must have the same label,
# 2-> degree of query vertix must be <= degree of target vertix
# 3-> amount of edge labels of query vertix mus be <= amount of edge labels of target vertix
#input1:  [Vertix] one Vertix object of the query graph 
#input2:  [Vertix] one Vertix object of the target graph
#return1:  [bool]   1 if all rueles are true, 0 if not
############################
sub isMatchPossible
{
    my $vQ = shift;
    my $vT = shift;
    my $ret = 1;
    
    if ($vQ->label ne $vT->label)
    {
        $ret = 0;
    }
    if ($vQ->degree > $vT->degree)
    {
        $ret = 0;
    }
    
    #here check if all of the adjecent edges of the query vertix  are also present in the target
    my %vQDegreeHash = %{$vQ->degreeHash};
    my %vTDegreeHash = %{$vT->degreeHash};
    
    foreach my $key (keys %vQDegreeHash)
    {
        if (!$vTDegreeHash{$key}) { # if the label of the query is not ifen in the target --> false
            $ret = 0;
            last;
        }elsif($vTDegreeHash{$key} < $vQDegreeHash{$key}) # if the amoutn of the specific label is not correct --> false
        {
            $ret = 0;
            last;
        } 
    }
    return $ret;  
}



############################
#pruneMatrix
# Prunes the matrix even further, checks if each neighbour of the given vertices are also valid

#input1:  [2D array ref ] the matrix to prune
#input2:  [2D array ref] Adjacency matrix of target graph
#input3:  [2D array ref] Adjacency matrix of query graph
#return1:  [2D array ref ] the pruned matrix
############################
sub pruneMatrix
{
    my @matrix = @{shift(@_)};
    my $adj_target = shift(@_);
    my $adj_query = shift(@_);
    
    for(my $i = 0;$i < scalar(@matrix);$i++)
    {
        for (my $j = 0;$j < scalar (@{$matrix[$i]}); $j++)
        {
            if ($matrix[$i][$j] == 1) # only check for the remaining 1s in the matrix
            {
                my @target_Neighbours = @{get1Columns($adj_target,$j)}; # all neighbours of the current row in the target adjacency matrix
                my @query_Neighbours = @{get1Columns($adj_query,$i)};  # all neighbours of the current row in the query adjacency matrix
                $matrix[$i][$j] = hasValidNeighbours(\@target_Neighbours,\@query_Neighbours,\@matrix);
            }
        }
    }
    return \@matrix;
}



############################
#hasValidNeighbours
# checks if all neighbours of the query vertix are also present in the target 
# use the already pruned matrix(for vertix labels, degrees and edge labels) to look up if the neighbours of the given vertices are valid
#input1:  [int array] all neighbours to given vertix in the target graph
#input2:  [int array] all neighbours to given vertix in the query graph
#input3:  [2D array ref] n X m matrix to look if the neighbours are valid
#return1:  [bool] 1 if valid, else 0
############################
sub hasValidNeighbours
{
    my @target_Neighbours = @{shift(@_)};
    my @query_Neighbours = @{shift(@_)};
    my @matrix = @{shift(@_)};
    
    foreach my $qn (@query_Neighbours)
    {
        my $valid = 0;
        foreach my $tn (@target_Neighbours)
        {
            if ($matrix[$qn][$tn] == 1) { # vertix qn could be mapped to vertix tn
                $valid = 1;
                @target_Neighbours = grep {$_ != $tn} @target_Neighbours; #remove tn from @target_Neighbours, because we don't want to map another qn to tn
                last; # therefore exit the loop know, we found what we searched for
            }
        }
        if ($valid == 0) { # if no mapping for qn was found in all tn, than this mapping is not possible, therefore this matrix position should contain a 0
            return 0; # not possible for vertices to match
        }  
    }
    return 1; 
}




############################
#get1Columns
# returns a list of coloum positions for the given row which has a 1 value, for the given matrix
#input1:  [2D array ref] a given matrix
#input2:  [int] the row you want to search
#return1:  [int array ref] contains the positions of the colum for the given row which has a 1
############################
sub get1Columns
{
    my $matrixref = shift;
    my $curRow = shift;
    
    my $m = scalar(@{$matrixref});
    my $n = scalar(@{@{$matrixref}[0]});
    my @matrix = @{$matrixref};
    my @retArray;
    
    for(my $col = 0;$col < $n;$col++)
    {
        if ($matrix[$curRow][$col] == 1) {
            push(@retArray,$col);
        }
    }
    return \@retArray; 
}





# clones a multidimensional array
sub clone {
    my $that = shift;
    my @self = ();

    for (@$that) {
        push(@self, [@{$_}]);
    }
    return @self;
}



############################
#enumEmbed
# enumerates all valid embeddings for the given matrix
# a valid embedding is a matrix containing only 0 or 1 with following rules: each row has exactly one 1, and each coloum not more than one 1.
# this function implemented as a recursive dept first tree search, branches are pruned if a row contains only 0 -->
# at each branch we only look for the unused Coloums, which would be the coloums with the 1s, and shuffle them, to get all possible embeddings
#input1:  [hash] a hash with entry of a coloum number if these coloum was used previous in the recursion(i.e. steps further up the recursion tree), this coloums need not be checked again 
#input2:  [int array] all neighbours to given vertix in the query graph
#input3:  [2D array ref] n X m matrix to look if the neighbours are valid
#return1:  [bool] 1 if valid, else 0
############################
sub enumEmbed
{
    my %usedColumns = %{shift(@_)};
    my $curRow = shift(@_);
    my $M_cloneRef = shift(@_);
    my @M_clone = clone($M_cloneRef);
    
    my $rows = scalar(@M_clone);
    my $cols = scalar(@{$M_clone[0]});
    
    if ($curRow == $rows) { # we are at a leaf, i.e. shuffled till the last row
        push(@embeddings,\@M_clone); # this embedding is correct
    }else
    {
        #print "looking for more possibilities further down the tree\n";
        my @unusedColumn = @{get1Columns(\@M_clone,$curRow)}; # only look for coloums with 1s, the 0 ones cannot be valid
        foreach my $curCol (@unusedColumn) # if no 1s were found at this row, --> this branch can be pruned (i.e. no loop and next recursive step)
        {
            if ($usedColumns{$curCol}) { #If i already used this coloum(i.e the vertix of the target graph) for this row(i.e. vertix of query), than i cannot use it at this recursive step anymore, --> limits the amount of calculations for embedding finding
                next;
            }
            for(my $j = 0 ; $j < $cols;$j ++) # Here  search for the first coloum, and set the value to 1 and all other values to 0
            {
                if ($curCol == $j) {
                    $M_clone[$curRow][$j] = 1;
                }else
                {
                    $M_clone[$curRow][$j] = 0;
                }
            }
            $usedColumns{$curCol} = 1; # set to used, because the used Coloum should not be treid in paths further down the tree
            enumEmbed(\%usedColumns,$curRow+1,\@M_clone); # go further down the tree(i.e. the row) and remember the coloums already used in this branch
            #print "now again in the previous recursive call\n";
            delete $usedColumns{$curCol}; # set to unused, because now wer are further up this branch, and this coloum could be used again for shuffling  
        }
    }
}


############################
#initializeGraph
# reads a graph input file and extracts the vertices and the edges for the given graph
# search with regex, Knode has to be format of /\d+\s{1}\w+$/  and edge has to be format of /\d+\s{1}\d+\s{1}.{1}$/
#
#input1:  [graph ref] graph object
#input2:  [string] path to the input file
############################
sub initializeGraph
{
    my $graph = shift(@_);
    my $file = shift(@_);
    
    my @edges;
    my @vertices;
    open(my $fh, '<',$file) or die "Coudn't open file $file due to $!\n";
   
    while (<$fh>) {
        if ($_ =~ /\d+\s{1}\w+$/) 
        {
            chop($_);
            push(@vertices,$_);
        }
        if ($_ =~ /\d+\s{1}\d+\s{1}.{1}$/) 
        {
            chop($_);
            push(@edges,$_);   
        }
    }
    close($fh);
    foreach (@vertices)
    {
        my $id = (split(/ /,$_))[0];
        my $label = (split(/ /,$_))[1];
        $graph->insertVertix($id,$label);
        if ($opt_v)
        {
            print "inserted Vertix $id  $label into graph\n";
        }
        
    }
    foreach (@edges)
    {
        
        my $start = (split(/ /,$_))[0];
        my $end = (split(/ /,$_))[1];
        my $label = (split(/ /,$_))[2];
        $graph->insertEdge($label,$start,$end);
        if ($opt_v)
        {
            print "Inserted Edge $start-$end $label to graph\n";
        }
    }
    $graph->initAdjacencyMatrix();
}


##################
##printMatrix
#input1:  [2D array ref] matrix to print
#print the matrix with row and coloum descriptions
#################
sub printMatrix
{
    my @matrix  = @{shift(@_)};
    print "\t";
    for(my $i = 0;$i < scalar(@{$matrix[0]});$i++)
    {
        print "$i\t";
    }
    print "\n";
    for(my $i = 0;$i < scalar(@matrix);$i++)
    {
        print "$i\t";
        foreach (@{$matrix[$i]})
        {
            print "$_\t";
        }
        print "\n";
    }
    print"\n\n";
}