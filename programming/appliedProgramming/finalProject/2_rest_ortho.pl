 #!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use lib::Eggnog;

my $usage= << "JUS";
  Title:   2_rest_ortho.pl (Restriction_Orthologs) Copyright by Mario Köstl, no changes allowed!!!
  usage:   perl 2_rest_ortho.pl
  
  options: -s1|species1  [REQUIRED]    ID found in eggnog for first species 
           -s2|species2  [REQUIRED]    ID found in eggnog for second species
           -s3|species3  [REQUIRED]    ID found in eggnog for third species, -1 for all other species
           -both|b                     b(both) = take all proteins found in species 1 AND species 2, but not for species 3. s(single) =Take all proteins from s1 which has homologs within s2, without s3. Default value = s
           -slp|slpath                 speciesList file PATH, default value = ./data/species_list.txt
           -me|members                 meNOG_Members file  PATH, default value = ./data/meNOG.members.tsv
           -ap|annopath                annotation file PATH, default = ./data/meNOG.annotations.tsv
           -rp|rpath                   results PATH, default = ./results/
           -help|h                     print this message
           -verbose|v                  print additional informations        
           -debug|d                    print debugging informations
  results: Calculates all genes present in species1 with homologs in species2 but without homologs in species3( or all other species if -1 was choosen). Arguments -both defines the amount of taken proteins. -s = only take proteins from s1 with homologs in s2, without s3. and -both b takes all the proteins from s1 and s2, without s3
       
        OUTPUT:
           -prints the amount of found genes
           -stores all the corresponding proteinIds in a separeted file in rpath, filename = "protIds_s1_s2_s3.txt"
           -finds the functional description of the groupId for the found proteins /genes and additional informations, stored in file in rpath, filename will be protFunc_s1_s2_s3.txt
        EXAMPLES:
           -find all proteins in human with homologs in pan which have no homologs in Mus muscullus:
                   perl 2_rest_ortho.pl -s1 9606 -s2 9598 -s3 10090
           -find all proteins in human and pan which are homologs and have no homolog in Mus musculuss:
                   perl 2_rest_ortho.pl -s1 9606 -s2 9598 -s3 10090 -both b
           -find all proteins in musculus which are homolog with rattus and have no homolog to any other species
                   perl 2_rest_ortho.pl -s1 10090 -s2 10116 -s3 -1 -both b
           -find all proteins in musculus and rattus which are homologs and have no homolog to any other species
                   perl 2_rest_ortho.pl -s1 10090 -s2 10116 -s3 -1 -both b

JUS

my $opt_help;
my $opt_d;
my $opt_v;
my $s1;
my $s2;
my $s3;
my $both="s";
my $specListPath;
my $membersPath;
my $annoPath;
my $respath;

GetOptions(
  "h|help|" => \$opt_help,
  "s1|species1=s" => \$s1,
  "s2|species2=s" => \$s2,
  "s3|species3=s" => \$s3,
  "b|both=s"	  => \$both,
  "slp|slpath=s" => \$specListPath,
  "me|members=s" => \$membersPath,
  "ap|annopath=s" => \$annoPath,
  "rp|rpath=s" => \$respath,
  "verbose|v" => \$opt_v,
  "debug|d" => \$opt_d);
    
#print usage if requested
if($opt_help){
  print $usage;
  exit;
}

if (!$s1 or !$s2 or !$s3) {
    print $usage;
    exit;
}

if(!$both or !($both eq "s" or $both eq "b")){
    print "no valid both carguments was given, set both to default value = s\n";
    $both ="s";
}
#check if every path is available, set to default if no valid
if (!$specListPath or (! -f $specListPath)) {
    print "no valid species list path inserted, slpath is set to ./data/species_list.txt \n";
    $specListPath = "./data/species_list.txt";
}
if (!$membersPath or (! -f $membersPath)) {
    print "no valid members path inserted, members path is set to ./data/meNOG.members.tsv \n";
    $membersPath = "./data/meNOG.members.tsv";
}
if (!$annoPath or (! -f $annoPath)) {
    print "no valid annotation file path inserted, annopath is set to ./data/meNOG.annotations.tsv \n";
    $annoPath = "./data/meNOG.annotations.tsv";
}

if (!$respath or (! -d $respath)) {
    print "no valid rpath inserted, dpath is set to ./results/ \n";
    $respath = "./results/";
}


#start with real program
my $resProtPath = $respath."protIds_".$s1."_".$s2."_".$s3.".txt";
my $resFuncProtPath = $respath."protFunc_".$s1."_".$s2."_".$s3.".txt";

if(lib::Eggnog->containSpecies($specListPath,$s1) and lib::Eggnog->containSpecies($specListPath,$s2) and ($s3 eq "-1" or lib::Eggnog->containSpecies($specListPath,$s3) )) # -1 is shurely not a specis, but is also allowed for species 3
{
    
    my ($sucess,$h_homo_ref) = lib::Eggnog->createTsvHash_member($membersPath); # just store all from the tsv file in a hash
    if(!$sucess){
        print "members TSVfile couldn't be parsed, program aborted\n";
        return 0;
    }    

    my @group_protArray = @{countHomoWithConstraints($s1,$s2,$s3,$h_homo_ref,$both)};
    
    print scalar @group_protArray," homologs with the given criteria were found\n";  
    if($opt_d)
    {  
        foreach (@group_protArray)
        {
            print "".(split(/\-/,$_))[1]."\n";
        }
    }
    #write all the protIds in a seperate file
    if(writeProtArrayToFile($resProtPath,\@group_protArray)){
        print("File $resProtPath was created\n");
    }
    else{
        print("protIds were NOT writen to File $resProtPath\n");
    }
    
    #write all the protIds with additional functional descripitons to a file
    my ($ret,$anno_h_ref) = lib::Eggnog->getTSVHash_anno($annoPath);
    if(!$ret){
        print "annotations TSVfile couldn't be parsed, program aborted\n";
        return 0;
    }  

    if(writeDescr($resFuncProtPath,$anno_h_ref,\@group_protArray)){
        print("File $resFuncProtPath was created\n");
    }
    else{
        print("protFunctDes were NOT writen to File $resFuncProtPath\n");
    }
}else
{
    print("inserted Species are not present in the eggNOG database, or eggnogs species_list file couldnt be opend!!\nProgramm will be aborted");
}


#######
#writeDescr
#
# writes a given array of groupIds and protIds to a file
#
#in1: outout filepath
#in2: hash that contains every line from the annotations file
#in3: array with strings containing groupId-protId for all the groups to write
#out1: 1 if succesfull, 0 if not
##############
sub writeDescr
{
  my $f= shift(@_);
  my %groupId_h = %{shift(@_)}; #
  my @group_protArray = @{shift(@_)};

  if(open(my $fh, ">", $f)){
    print $fh "groupId\tprotId\tprotCount\tfunctId\tdesc\n";
    foreach (@group_protArray)
    {
        my $groupId = (split(/\-/,$_))[0];
        my $protId = (split(/\-/,$_))[1];
        my $protCount = $groupId_h{$groupId}[0];
        my $functId = $groupId_h{$groupId}[1];
        my $desc = $groupId_h{$groupId}[2];
        
        if($opt_v){
            print("\n------------------\n");
            print("groupId= $groupId\n");
            print("protId= $protId\n");
            print("protCount= $protCount\n");
            print("functId= $functId\n");
            print("desc= $desc\n");
        }
        print $fh $groupId."\t".$protId."\t".$protCount."\t".$functId."\t".$desc."\n";       
    }
    close($fh);
    return 1;
  }else{
      print "Couldn't open '".$f."' for writing because: ".$!."\n";
  }
  return 0;
}

#######
# writeProtArrayToFile
#writes an array of protIds to a given file
#
#in1: output filepath
#in2: array of protIds for writing
#ret1: 1 if succesful, 0 if not
######
sub writeProtArrayToFile
{
  my $f = shift(@_);
  my @array = @{shift(@_)};
 
  if(open(my $fh, ">", $f)){
      foreach(@array)
      {
          my $prot = (split(/\-/,$_))[1]."\n";
          print $fh $prot;
      }
      close($fh);
      return 1;
  }else{
      print "Couldn't open '".$f."' for writing because: ".$!."\n";
  }
  return 0;
  
}

######
#countHomoWithConstraints
#
#Finds homolog proteins for given criteria(more details can be found in --help)
#
#in1: Id of first species
#in2: Id of second species
#in3: Id of third species, or -1 for every other species
#in4: both describes how to pick proteins, b = take proteins from s1 and s2, s = only take proteins from s1
#in4: Hash that represents the members tsv file
#ret1: array of found proteins with following format : "groupId-protId"
######
sub countHomoWithConstraints
{
    my $s1 = shift(@_);
    my $s2 = shift(@_);
    my $s3 = shift(@_);
    my %h_homo = %{shift(@_)};
    my $both = shift(@_);
    
    my @group_protArray; 
    
    foreach my $groupId (keys %h_homo) # check every possible groupId
    {
        my @taxProtArray = @{$h_homo{$groupId}};
        if($opt_d)
        {
            print "TaxProtArray = @taxProtArray\n";
        }
        
        my $isS1present= 0 ; 
        my $isS2present= 0 ;
        my $isS3present= 0 ;
        my $prot1; # stores the found protID for the species1, will be used outside of the loop to store the homolog protein
        my $prot2; # stores the found protID for the species2, will only be used with -both option b
        foreach my $taxProt(@taxProtArray) # loop all taxProt strings for this groupId
        {
            my $taxId = (split(/\./,$taxProt))[0];
            my $protId = (split(/\./,$taxProt))[1];
            
            if($opt_d)
            {
                print "TaxId = $taxId\tProtId = $protId\n";
                print "s1 = $s1\ts2=$s2\n";
            }
            
            if ($s1 eq $taxId) {
                $isS1present=1;
                if($opt_d)
                {
                    print "$s1 is present in this group\n";  
                    print "found protId for $s1 = $protId\n"; 
                }
                $prot1 = $protId; # store this for later usage, S1 should be only one times in the list i assume

            }
            if ($s2 eq $taxId) {
                $isS2present=1;
                if($opt_d)
                {
                    print "$s2 is present in this group\n";  
                    print "found protId for $s2 = $protId\n"; 
                }
                $prot2 = $protId;
            }
            if ($s3 eq $taxId or ($s3 eq "-1" and scalar @taxProtArray>2)) { # if the amount of taxProt > 2, than there is at least one other homolog here, which means if s3 = -1 this groupId should not be pushed into the returning array
                $isS3present=1;
                if ($opt_d)
                {
                    print "$s3 is present in group $groupId, $groupId will not be taken\n";
                }
            }   
        }
        if ($isS1present and $isS2present and !$isS3present) # s1 and s2 have proteins in this group, but s3 should not have a homolog, orno other species should be presented if both -1 was choosen
        {
            push(@group_protArray,$groupId."-".$prot1); # everything seems fine, take this groupId
            if($both eq "b"){ # also insert proteinId from s2
                 push(@group_protArray,$groupId."-".$prot2); 
            }
            if ($opt_d)
            {
                print " homologs found, counter = ",scalar @group_protArray,"\n";
            }  
        }else
        {
            if ($opt_d)
            {
                print "no homolog found for this group or $s3 has also homologs\n counter = ",scalar @group_protArray,"\n";
            }
        }
    }
    return \@group_protArray;
}
