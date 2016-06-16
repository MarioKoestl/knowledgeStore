#!/usr/bin/perl
use warnings;
use strict;
use Class::Struct;

struct(Vertix=> {
    label => '$',
    out => '@', # all vertexes with outedges for this vertix
    in => '@',
    seen => '$',
    next => '$',
});

use Getopt::Long;

my $usage= << "JUS";
  Title:   kletShuffling
  usage:   klet_shuffling_mkoestl.pl -seq [sequence] -k [klet] -n [howMany]
  
  options: -seq|s  [REQUIRED]    sequence as string
           -k|klet               klet, default = 2
           -n                    how many sequences should be created, default =1
           -help|h               print this message
           -verbose|v            print additional informations        
        
  results: Shuffles the given sequence and keeping the klet count, solutions are even distributed. calculated the average, standard devviation and variance for the solution sequences
JUS



my $opt_help;
my $seq;
my $opt_v;
my $opt_k=2;
my $opt_n=1;

GetOptions(
  "h|help|" => \$opt_help,
  "seq|s=s" => \$seq,
  "klet|k=s" => \$opt_k,
  "n=i" => \$opt_n,
  "verbose|v" => \$opt_v);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}
if (!$seq) {
    print $usage;
    exit;
}


my @klets = get_klets($seq);
my %vertices = get_k1lets($seq); # hash of vertices for each k1let;

print "\n\n-----------START OF KLET SHUFFLING-------\n#####################\n";
print "We found following Klets : \n";
foreach (@klets)
{
   print "$_\n";
}
print "\n";
print "we create following Vertices = k-1lets\n";
foreach (keys %vertices)
{
   print "$_\n";
}
printHash(\%vertices);

print "INPUT SEQ    = $seq\n";

my @seqArray;
my $new_seq;
my %countHash;
my @wrongSeqs;
for(my $i =0;$i<$opt_n;$i++)
{
    %vertices = get_k1lets($seq); # hash of vertices for each k1let;
    $new_seq = getWilsonPath(\%vertices);
    
    if (check_klet($seq,$new_seq)) {
        
        if($countHash{$new_seq})
        {
            $countHash{$new_seq} += 1;
        }else
        {
            $countHash{$new_seq} = 1;
        }
    }else{
        push(@wrongSeqs,$new_seq);
    }
}

print "Following solutions were found :\n";
foreach (keys %countHash)
{
    print "$_ -> ",$countHash{$_},"\n";
}
my @values = values %countHash;

print "Average = ",&average(\@values),"\n";
print "Std = ",&stdev(\@values),"\n";
print "Variance = ",sqrt(&stdev(\@values)),"\n";


print scalar(@wrongSeqs)," out of $opt_n found sequences do NOT have the same klet count!!!!";


sub getWilsonPath
{
    # get random arborescenceTree
    my %vertices = %{shift(@_)};
    if (!(isEulerCircuit(\%vertices) or hasEulerPath(\%vertices))) {
        print "Error, path has no euler path or circuit\n";
        exit;
    }
    
    my $start =  substr($seq,0,$opt_k-1);# first k-1let
    my $end = substr($seq,-($opt_k-1));
    
    print "start = $start\n";
    print "end = $end\n";
    
    
    $vertices{$end}->next("fin");
    $vertices{$end}->seen(1);
    
    my $curV;
    if($opt_v)
    {
        print "matrix before initialisation\n";
        printMatrix(\%vertices);
    }
    
    
    foreach my $vertix (keys %vertices)
    {
        if($opt_v)
        {
            print "curV = $curV\n";
        }
        $curV=$vertix;
            
        while ($vertices{$curV}->seen == 0) #loop till we found a loop, or the end
        {
            if($opt_v)
            {
                print "$curV wasnt visited yet\n"; 
            }
            my @outEdges = @{$vertices{$curV}->out};
            my $rand = int(rand(scalar(@outEdges)));
            $vertices{$curV}->next($outEdges[$rand]); # choose a randomly outgoing edge, and store how to get from our currentVertex to this new vertix
            
            if($opt_v)
            {
                print "we chose $outEdges[$rand] as next Vertex\n";
            }
            $curV = $outEdges[$rand]; # now our currentV is this next vertix
            if ($opt_v) {
                printMatrix(\%vertices);   
            }

            
        }
        if($opt_v)
        {
            print "LOOP end because ",$vertices{$curV}->label," was already visited\n";
        }
        $curV = $vertix; #now set the path
        while ($vertices{$curV}->seen == 0) #loop till we found a loop, or the end, and now check each vertix visited
        {
            $vertices{$curV}->seen(1);
            $curV = $vertices{$curV}->next;
            if ($opt_v) {
                printMatrix(\%vertices);   
            }
        }
       
       
    }
    if($opt_v)
    {
        print "matrix after filling\n";
        printMatrix(\%vertices);
    }
    
    
    foreach my $vertix (keys %vertices)
    {
        
    
        ##shuffle the outgoingEdges but the next element has to be the last in the array afterwards
        #--> remove one occurence of next in array
        
        #if ($vertices{$vertix}->next) {
         #   #code
        #}
        
        my $index = 0;
        my @outEdges = @{$vertices{$vertix}->out};
        my $nextV = ($vertices{$vertix})->next;
        if($opt_v)
        {
            print("curVertix = $vertix\n");
            print("outEdges are @outEdges\n");
            print("nextVertix = $nextV\n");
            print("index = $index\n");
        }        
        
        if ($nextV eq "fin") {
            my @shuffled = kfy_shuffle(\@outEdges);
            $vertices{$vertix}->out(\@shuffled); # only shuffle the out array
            push(@shuffled,"fin");
            if($opt_v)
            {
                print("shuffled array  = ",@{$vertices{$vertix}->out},"\n");
            }
        }else
        {
            while ($outEdges[$index] ne $nextV) {
                $index++;
            }
            
            splice(@outEdges, $index, 1);
            if($opt_v)
            {
                print("outEdges -1 are @outEdges\n");
            }
            # than shuffle the remaining out edges array
            my @shuffled = kfy_shuffle(\@outEdges); # only shuffle the out array
            if($opt_v)
            {
                print("shuffled array  = @shuffled\n");
            }
            ### and than insert the next vertix at the last position of the outEdges array
            push(@shuffled,$nextV);
            $vertices{$vertix}->out(\@shuffled);
           # $vertices{$vertix}->out(0);
            
            if($opt_v)
            {
                print("completely shuffled array  = ",@{$vertices{$vertix}->out},"\n");
            }
        } 
        
    }
    if($opt_v)
    {
        print "matrix after shuffling\n";
        printMatrix(\%vertices);
    }
    
    
    
    #now go along the path from the start to the end
    
    my $finalSeq = "";#substr($start,0,1);
    if($opt_v)
    {
        print "Now getting path, starting with $start\n";
    }
    while ($start ne "fin") {
        #printMatrix(\%vertices);
        #print "at vertix $start\n";
        #print "have outEdges of ",@{$vertices{$start}->out},"\n";
        my $nextV = shift(@{$vertices{$start}->out});
        #print "nextV =  $nextV \n";
       
        if ($nextV ne "fin") {
            $finalSeq .= substr($start,0,1);
        }else
        {
            $finalSeq .= $start;
        }
       
        if ($start eq "fin") {
            
            last;
        }
 
        #print "finalSeq = $finalSeq\n";
        $start = $nextV;
        #my $in=<STDIN>;
    }
    if($opt_v)
    {
        print("\nWHOLE final sequence = $finalSeq\n");
    }
    
    return $finalSeq;    
}

sub kfy_shuffle
{
    my @seq = @{$_[0]};
    my $n = scalar(@seq);
    if (scalar(@seq <= 1)) {
        return @seq; #no shuffling possible
    }
    
    for (my $i=0;$i<$n-1;$i++)
    {
        my $r = int(($i) + rand(($n-1+1) - ($i))); # random number between $i and n-1
        ($seq[$i],$seq[$r]) = ($seq[$r],$seq[$i]);
    }
    
    return @seq;
}

sub printMatrix
{
    my %vertices =%{shift(@_)};
    print "\nlabel\tout\tseen\tnext\n";
    foreach my $k (sort keys %vertices)
    {
        my $v = $vertices{$k};
        print("$k\t",@{$v->out},"\t",$v->seen,"\t",$v->next,"\n");
    }
}
sub check_klet{
    my $seq1 = shift(@_);
    my $seq2 = shift(@_);

    
    my @klets = get_klets($seq);
    my @seq1_klets = get_klets($seq1);
    my @seq2_klets = get_klets($seq2);
    
    if ($opt_v) {
        print "CHeck if the sequences have the same klet-counts\n";
        print "klets of seq1 = ", join(',',sort @seq1_klets ),"\n";
        print "klets of seq2 = ", join(',',sort @seq2_klets ) ,"\n";
    }
    
    my %diff;
    @diff{ @seq1_klets } = undef;
    delete @diff{ @seq2_klets };
    
    if (keys %diff >0) {
        print "ERROR, sequence $seq2 has not the same amount of $opt_k lets as sequence $seq1\n";
        return 0;
    }else
    {
        #print "JUCHU, sequence @seq2 has the same amount of $opt_k lets as sequence @seq1\n";
        return 1;
    }
    
}

#1 if EUlerCircuit, 0 if not
#funktioniert
sub isEulerCircuit
{
    my %vertices = %{shift(@_)};
    
    foreach my $key (keys %vertices)
    {
        if ((scalar @{$vertices{$key}->out}) != (scalar @{$vertices{$key}->in})) {
            return 0;
        }
    }
    return 1;
}


sub hasEulerPath
{
    my %vertices = %{shift(@_)};
    my $start="";
    my $end ="";
    if($opt_v)
    {
       print "START hasEulerPath\n\n";
   
    }
    foreach my $key (keys %vertices)
    {
        if($opt_v)
        {
            print "curV = $key\n";
            print "out = ", scalar @{$vertices{$key}->out} ,"\n";
            print "in = ", scalar @{$vertices{$key}->in} ,"\n";
            print "Start = $start\n";
            print "End = $end\n";
        }
        if (abs((scalar @{$vertices{$key}->out}) - (scalar @{$vertices{$key}->in})) > 2)
        {
            return (0,$start,$end);
        }elsif((scalar @{$vertices{$key}->out}) - (scalar @{$vertices{$key}->in}) == 1)
        {# one out more than in = start
            if ($start ne "") {
                if($opt_v)
                {
                  print("found another start -> not allowd, no euler path\n");
                }
                return (0,$start,$end);  # start was already found, a second start is not allowed
            }
            $start = $key;
            if($opt_v)
            {
                print("found a start = $start\n");
            }
        }elsif((scalar @{$vertices{$key}->in}) - (scalar @{$vertices{$key}->out}) == 1)
        {#one in more than out = end
            if ($end ne "") {
                if($opt_v)
                {
                    print("found another $end -> not allowd, no euler path\n");
                }
                return (0,$start,$end); # end was already found, a second end is not allowed
            }
            
            $end = $key;
            if($opt_v)
            {
                print("found a end = $end\n");
            }
         }
    }
    
    if ($start and $end) {
        return (1,$start,$end);
    }else
    {
        return (0,$start,$end);
    }
}
sub get_klets
{
    my @dna = split(//,$_[0]);
    my @klets;
    for(my $i=0;$i< scalar(@dna)-($opt_k-1);$i++)
    {
        my $klet = join('',@dna[$i...($i+$opt_k-1)]);      
        push(@klets,$klet); 
    }
    return @klets;
}

sub get_k1lets
{
    my @seq = split(//,$_[0]);
    my %k1lets;
    for(my $i=0;$i< scalar(@seq)-($opt_k-2);$i++)
    {
        my $k1let = join('',@seq[$i...($i+$opt_k-2)]);
        my $vertix = Vertix->new();
        $vertix->label($k1let);
        $vertix->out(0);
        $vertix->in(0); # set all out and in edges to 0
        $vertix->seen(0);
        $vertix->next("udef");
        $k1lets{$k1let}=$vertix;
    }
    
    for(my $np=0;$np<(scalar(@seq)-($opt_k-1));$np++) 
    {
        my $k1let = join('',@seq[$np...$np+($opt_k-2)]);
        my $k1let_next = join('',@seq[$np+1...($np+1+$opt_k-2)]); 
        push(@{$k1lets{$k1let}->out},$k1let_next); # add an outgoing edge to this vertex
        push(@{$k1lets{$k1let_next}->in},$k1let);
        
    }
    
    ####remove all vertices without in or outgoing edges. f.E. CGAC and k =3, GA doesn't have anything
    foreach my $key (keys %k1lets)
    {
        if (scalar @{$k1lets{$key}->out} == 0 and scalar @{$k1lets{$key}->in} == 0) {
            delete $k1lets{$key};
        }
    }
    return %k1lets;
}


sub printHash
{
    my %hash = %{shift(@_)};
    foreach (sort keys %hash)
    {
        print "\nVertex = $_ :\nOutgoing to : ", join(' ',@{$hash{$_}->out}) . "\nIngoing from : ", join(' ',@{$hash{$_}->in}),"\n"; 
    }
}

sub average{
        my($data) = @_;
        if (not @$data) {
                die("Empty arrayn");
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}