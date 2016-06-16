#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
require mks_perl_tools;
# to use this package you need of course the mks_perl_tools.pl file,
# and you have to export the $PYTHEN5LIB Variable to the directory of this package.
# change/export $PYHTON5LIB variable either by command line, or defined within your own bashrc
# If you don't want to export the varibale simple define the whole path of the package after the require statement



use Getopt::Long;

my $usage= << "JUS";
  
  usage:   mkoestl_Ex03.pl -path [PATH]
  
  options: -path|p    Path to data [REQUIRED]
           -help|h    print this message
       
  results: Example:03 for applied Programming lecture
JUS

my $help;
my $PATH=0;


GetOptions(
  "h|help|" => \$help,
  "path|p=s" => \$PATH);
    
#print usage if requested
if($help){
  print $usage;
  exit;
}
#check if the directory exists
unless(-d $PATH){
  print "ERROR $PATH does not exist \n\n$usage";
  exit;
}


#1 and #6

my $f = "$PATH/swissprot_list.txt";
my $f_out = "$PATH/swissprot_accession_numbers.txt";
my $fh_out;
unless(open $fh_out,'>'.$f_out)
{
    die "Couldn't create'".$f."' because: ".$!;
}

my @l = fileToArray($f);
foreach (@l)
{
    my @matches = $_ =~ /\([A-Z]\d+\)/g; # check in the lines for the accesion numbers with ()
    
    if ($_ =~ /HUMAN/g) { #6 to only print human receptors check for a regix with HUMAN
        foreach (@matches)
        {     
            print $fh_out $_ . "\n";
        }
    }
}
close $fh_out;

#2
print "\n#2######################\n";
print reorderColumns("$PATH/gene_positions1.txt");

#############################
###reorderColumn###
#returns the reorder table from the read file
#input 1 filepath: path to file
#return 1: string filled with the reorderd table
#############################
sub reorderColumns
{
    $f= shift(@_);
    
    my @lines = fileToArray($f);
    #shift(@lines); # remove header line

    my @spl;
    my $reordered="";
    foreach (@lines)
    {
        @spl = split(/\t/,$_);
        $reordered.= "$spl[2]\t$spl[0]\t$spl[1]\t$spl[3]\t$spl[4]\n";
    }
    return $reordered;
}
#3

my @gene_files =getFilesFromDir($PATH,1,'gene_position*');

my $f_handle;
my $newFilePath="";
foreach my $filepath (@gene_files)
{
    if ($filepath =~ /.+reordered\.txt/) {
        next;
    }
    
    my $filename = (split(/\./,basename($filepath)))[0];
    $newFilePath = dirname($filepath) . "\/$filename\.reordered\.txt";
    
    unless(open $f_handle,'>'.$newFilePath)
    {  
        die "Couldn't create'".$newFilePath."' because: ".$!;
    }
    
    my $newColumnString= reorderColumns($filepath);
    print $f_handle "$newColumnString";
    close $f_handle;
}


#4
print "\n#4######################\n";
my $filePath = "$PATH/names.txt";

my %hash = readMatrixToHash($filePath);
foreach my $key (sort{lc $a cmp lc $b} keys %hash) {
	print $key, ": ", $hash{$key} , "\n";
}

print get_country_by_name(\%hash,"Barack");

sub get_country_by_name
{
    my %hash = %{shift(@_)};
    my $name = shift(@_);
    
    if (exists $hash{$name}) {
        return $hash{$name};
    }else
    {
        return "Name $name wasn't found in the hash_you could check case-sensitivity\n";      
    }
}



#5
print "\n#5######################\n";
$filePath = "$PATH/gene_positions1.txt";
my @lines = fileToArray($filePath);
shift(@lines); # to remove the header line
my %hash_chromo;

foreach (@lines)
{
    my @lineSplit = split(/\t/,$_);
     
    
    my $chromo = $lineSplit[2];
    if (exists $hash_chromo{$chromo}) {
        $hash_chromo{$chromo} +=1;
    }else{
        $hash_chromo{$chromo} =1;
    } 
}

foreach my $key (keys %hash_chromo) {
	print $key, ": ", $hash_chromo{$key} , "\n";
}








