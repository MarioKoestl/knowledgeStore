#!/usr/bin/perl
package ConnectData;

use warnings;
use strict;
use base 'Exporter';

our @EXPORT_OK = qw($DB_USER $DB_PASSWD $DATABASE);

our $DB_USER = 'mario';
our $DB_PASSWD = 'mario';
our $DATABASE = 'bio';

1;
