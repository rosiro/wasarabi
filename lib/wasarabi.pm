package wasarabi;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use wasarabi::DB;
use Time::Piece;
use parent qw/Amon2/;
# Enable project local mode.
__PACKAGE__->make_local_context();

use Amon2::Config::Simple;

sub db {
    my ($self, $c) = @_;
    if (!defined $self->{db}) {
        my $conf = $self->config->{'DBI'} or die "missing configuration for 'DBI'";
        my $dbh = DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{connect_options});
        $self->{db} = wasarabi::DB->new({ dbh => $dbh });
    }
    return $self->{db};
}

sub datetime {
    my ($self, $c) = @_;
    my $timepiece = Time::Piece::localtime();
    $self->{datetime} = $timepiece;
    return $self->{datetime};
}

sub config {
    return Amon2::Config::Simple->load(shift);
}

1;

__END__

=head1 NAME

wasarabi - wasarabi

=head1 DESCRIPTION

This is a main context class for wasarabi

=head1 AUTHOR

wasarabi authors.

