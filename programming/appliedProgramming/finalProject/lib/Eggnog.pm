#!/usr/bin/perl

#Eggnog.pm Copyright by Mario Köstl, no changes allowed!!!

package lib::Eggnog;
use warnings;
use strict;


####
#createTsvHash_member
#
#Read every line from members.tsv file and store the data into a hash, that now represents all homolog genes for a given GroupId
# Hash key = GroupId, hash value = list of "TaxonId.ProteinId"
# 
#in1: modulename
#in2: path to members tsv file
#ret1: successfull creation of hash
#ret2: hash
#######
sub createTsvHash_member
{
    shift(@_);  # first parameter is the module name itself
    my $f = shift(@_);
    my %hash;
    my $success=0;    

    if(open(my $fh, "<", $f)){
        while(my $line = <$fh>){
            chomp($line);
            my @split = split(/\t/,$line);
            my @list = split(/,/,$split[5]);
            $hash{$split[1]}=\@list;
        }
        close($fh);
        $success=1;
    }else{  
            print "Couldn't open '".$f."' for reading because: ".$!."\n";
    }    
    return ($success,\%hash); 
}

####
#getTSVHash_anno
#
#Read every line from annotations.tsv file and store the data into a hash
# Hash key = GroupId, hash value = list of protein count for this groupId, the corresponding functionalId and a desc
# 
#in1: modulename
#in2: path to annotations tsv file
#ret1: successfull creation of hash
#ret2: hash
#######
sub getTSVHash_anno
{
    shift(@_);  # first parameter is the module name itself
    my $f = shift(@_);
    my %hash;
    my $success=0;    
    
    if(open(my $fh, "<", $f)){

        while(my $line = <$fh>){
            chomp($line);
            my @split = split(/\t/,$line);
            my @list; # this list contains the protein count for this groupId, the corresponding functionalId and a description
            push(@list,$split[2]);
            push(@list,$split[4]);
            push(@list,$split[5]);
            $hash{$split[1]}=\@list;
        }
        close($fh);
        $success=1;
    }else{
        print "Couldn't open '".$f."' for reading because: ".$!."\n";
    }

    return ($success,\%hash); 
}


######
#containSpecies
#checks if the given Id is inside the species_list file of eggnog
# 
#in1: moduleName
#in2: path to species_list file
#in3: speciesId
#ret1: 1 if Id is known by eggnog, 0 if not
###
sub containSpecies
{
    shift(@_); #first parameter is the module name itself
    my $f = shift(@_);    
    my $id = shift(@_);
    if(open(my $fh, "<", $f)){
        while(my $line = <$fh>){
            my @split = split(/\t/,$line);
        
            if($split[1] eq $id)
            {
                return 1;
            }
        }
     }
    else{     
        print "Couldn't open '".$f."' for reading because: ".$!."\n";
        return 0;
     }
return 0;
    
}


return 1;
