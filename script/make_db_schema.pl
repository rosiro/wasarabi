use strict;
use warnings;
use utf8;
use Teng::Schema::Dumper;
use Teng::Schema::Declare;

use lib 'lib';
use wasarabi;
use wasarabi::DB;
use Data::Printer;

my $fname = File::Spec->catfile('config', "development.pl");
my $config = do $fname or die "Cannot load configuration file: $fname";
my $conf = $config->{'DBI'} or die "missing configuration for 'DBI'";
my $dbh = DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{connect_options});


my $schema = Teng::Schema::Dumper->dump(
    dbh => $dbh,
    namespace => 'wasarabi::DB',
    );

print $schema;
