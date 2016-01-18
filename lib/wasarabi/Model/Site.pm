package wasarabi::Model::Site;
use 5.10.0;
use strict;
use warnings;
use utf8;
use Data::Printer;

sub site_check {
    my ($self,$c) = @_;

    my $site_url = $c->{site_url};
    my $db = $c->{db};

    my $site = $db->lookup('site',{ url => $site_url });
    if($site){
	return $site;
    }
    else{
	return undef;
    }
}

1;
