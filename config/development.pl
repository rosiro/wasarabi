use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $dbpath = File::Spec->catfile($basedir, 'db', 'development.db');
+{
    'DBI' => {
        dsn => 'dbi:mysql:dbname=wasarabi',
        username => '',
        password => '',
        connect_options => {
            mysql_enable_utf8 => '1',
            on_connect_do => [ "SET NAMES 'utf8'", "SET CHARACTER SET 'utf8'"],
        },
    },
};
