package wasarabi::Web;
use strict;
use warnings;
use utf8;
use parent qw/wasarabi Amon2::Web/;
use wasarabi::Model::Site;
use File::Spec;
use Data::Printer;
use Log::Minimal;

# dispatcher
use wasarabi::Web::Dispatcher;
sub dispatch {
    return (wasarabi::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::JSON',
    '+wasarabi::Web::Plugin::Session',
);

# setup view
use wasarabi::Web::View;
{
    sub create_view {
        my $view = wasarabi::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *wasarabi::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
	my $c = shift;
	my $nowhost = $c->req->env->{HTTP_HOST};
	infof("HTTP_HOST:".$nowhost);
	my $site = wasarabi::Model::Site->site_check({
	    'site_url' => $nowhost,
	    'db' => $c->db });
	$c->{site} = $site;
	infof("--------------------------");
	infof("SITE URL:".$site->url);
	infof("SITE TITLE:".$site->title);

	my $p_post = "No";
	if($site->permission_post_user == 1){
	    if($c->{user}->{login} && $c->{user}->{login} == 'yes'){
	    }
	    else{
	    }
	}
	else{
	}
	infof("SITE PERMISSION POST:".$p_post);

	my $p_view = "No";
	if($site->permission_view_user == 1){
	    if($c->{user}->{login} && $c->{user}->{login} == 'yes'){
	    }
	    else{
	    }
	}
	else{
	    $p_view = "YES";
	}
	infof("SITE PERMISSION VIEW:".$p_view);

	my $p_comment = "No";
	if($site->permission_comment_user == 1){
	    if($c->{user}->{login} && $c->{user}->{login} == 'yes'){
	    }
	    else{
	    }
	}
	else{
	}
	infof("SITE PERMISSION COMMENT:".$p_comment);

	# Login only site check
	my @login_ignore_paths = ('/login','/register');
	if($p_view eq "No"){
	    for my $login_ignore_path (@login_ignore_paths){
		if( $c->req->path =~ m/^$login_ignore_path/){
		}
		else{
		    $c->redirect('/login');
		}
	    }
	}

	return;
    },
);

1;
