#!/usr/bin/perl
use DBI;

use ConnectData qw($DB_USER $DB_PASSWD $DATABASE);
use lib '.';

my $dbh = DBI->connect("DBI:mysql:database=$DATABASE",$DB_USER,$DB_PASSWD) or die "couldn't connect to database: ". DBI->errstr;

my $query = $dbh->prepare("select * from person WHERE firstname=?");


print "Enter Name: ";
my $firstname = <STDIN>; chomp($firstname);

$query->execute($firstname) or die $query->err_str;

#my @cols = $query->fetchrow_array();


while (my @data= $query->fetchrow_array())
{
    foreach (@data)
    {
        print"$_\n";
    }
#    print "COl1 : $col1\n";
 #   print "COl2 : $col2\n";
  #  print "COl3 : $col3\n";
}


$dbh->disconnect();

