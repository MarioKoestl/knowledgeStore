 #!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use lib::Eggnog;

my $usage= << "JUS";
  Title:   1_ortho.pl
  usage:   perl 1_ortho.pl -s1 [speciesId1] -s2 [speciesId2] Copyright by Mario Köstl, no changes allowed!!!
  
  options: -s1|species1  [REQUIRED]    ID found in eggnog for first species 
           -s2|species2   [REQUIRED]   ID found in eggnog for second species
           -slp|slpath                 speciesList file PATH, default value = ./data/species_list.txt
           -me|members                 meNOG_Members file  PATH, default value = ./data/meNOG.members.tsv
           -help|h               print this message
           -verbose|v            print additional informations        
        
  results: returns the amount of genes of species1 that are homolog with species 2
JUS
my $opt_help;
my $opt_v;
my $s1;
my $s2;
my $specListPath;
my $membersPath;


GetOptions(
  "h|help|" => \$opt_help,
  "s1|species1=s" => \$s1,
  "s2|species2=s" => \$s2,
  "slp|slpath=s" => \$specListPath,
  "me|members=s" => \$membersPath,
  "verbose|v" => \$opt_v);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (!$s1 or !$s2) {
    print $usage;
    exit;
}
if (!$specListPath or (! -f $specListPath)) {
    print "no valid species list path inserted, slpath is set to ./data/species_list.txt \n";
    $specListPath = "./data/species_list.txt";
}
if (!$membersPath or (! -f $membersPath)) {
    print "no valid members path inserted, members path is set to ./data/meNOG.members.tsv \n";
    $membersPath = "./data/meNOG.members.tsv";
}


if(lib::Eggnog->containSpecies($specListPath,$s1) and lib::Eggnog->containSpecies($specListPath,$s2))
{
    my ($sucess,$h_homo_ref) = lib::Eggnog->createTsvHash_member($membersPath); # just store all from the tsv file in a hash
    if(!$sucess){
        print "members TSVfile couldn't be parsed, program aborted\n";
        return 0;
    }    
    print "Amount of homologs= ", countHomo($s1,$s2,$h_homo_ref),"\n";   
}else
{
    print("inserted Species are not present in the eggNOG database!!\n");
}

######
#countHomo
#
#Finds homolog proteins for given criteria(more details can be found in --help)
#
#in1: Id of first species
#in2: Id of second species
#in4: Hash that represents the members tsv file
#ret1: #the amount of homolog proteins between species s1 and s2
######
sub countHomo
{
    my $s1 = shift(@_);
    my $s2 = shift(@_);
    my %h_homo = %{shift(@_)};
    
    my $counter=0;
    foreach my $groupId (keys %h_homo)
    {
        my @taxProtArray = @{$h_homo{$groupId}};
        if($opt_v)
        {
            print "TaxProtArray = @taxProtArray\n";
        }   
        my $isS1present= 0 ; 
        my $isS2present= 0 ; 
        foreach my $taxProt(@taxProtArray) # loop all taxProt strings for this groupId
        {
            #print "TaxProtString = $taxProt\n";
            my $taxId = (split(/\./,$taxProt))[0];
            my $protId = (split(/\./,$taxProt))[1];
            
            if($opt_v)
            {
                print "TaxId = $taxId\tProtId = $protId\n";
                print "s1 = $s1\ts2=$s2\n";
            }
            
            if ($s1 eq $taxId) {
                $isS1present=1;
                if($opt_v)
                {
                    print "$s1 is present in this group\n";
                }
            }
            if ($s2 eq $taxId) {
                $isS2present=1;
                if ($opt_v)
                {
                    print "$s2 is present in this group\n";
                }     
            }         
        }
        if ($isS1present and $isS2present) { # both species have proteins in this group, therefore they have this protein homolog and we count it
            $counter+=1;
            if ($opt_v)
            {
                print " homologs found, counter = $counter\n";
            }  
        }else
        {
            if ($opt_v)
            {
                print "no homolog found for this group counter = $counter\n";
            }
        }
    }
    return $counter;
}




