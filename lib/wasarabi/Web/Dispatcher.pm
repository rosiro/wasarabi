package wasarabi::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use wasarabi::Model::Wiki;
use Data::Printer;

any '/' => sub {
    my ($c) = @_;
    my $counter = $c->session->get('counter') || 0;
    $counter++;
    $c->session->set('counter' => $counter);
    return $c->render('index.tx', {
        counter => $counter,
		      });
};

post '/reset_counter' => sub {
    my $c = shift;
    $c->session->remove('counter');
    return $c->redirect('/');
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    return $c->redirect('/');
};

any '/account/setting' => sub {
    my ($c) = @_;
    return $c->redirect('/');
};

get '/wiki/:pagename' => sub {
    my ($c, $args) = @_;
    my $counter = $c->session->get('counter') || 0;
    $counter++;
    my $wiki = wasarabi::Model::Wiki->load_wiki({
	'db' => $c->db,
	'title' => $args->{pagename} });
    if($wiki){
	return $c->render('wiki.tx', {
	    counter => $counter,
	    wiki => $wiki,
			  });
    }
    else{
	$c->res_404();
    }
};

get '/wiki_create' => sub {
    my ($c) = @_;
    return $c->render('wiki_create.tx', {
		      });
};

post '/wiki_create' => sub {
    my ($c) = @_;
    my $check_results = wasarabi::Model::Wiki->validate_wiki({ 'request' => $c->req });
    if($check_results->{title} || $check_results->{honbun} ) {
	$c->fillin_form($c->req);
	return $c->render('wiki_create.tx', {
	    check_results => $check_results,
			  });
    }
    else{
	if($c->req->param('check_wiki') && $c->req->param('check_wiki') eq 'ok'){
	    my $create_results = wasarabi::Model::Wiki->create({
		request => $c->req,
		db => $c->db,
		account_id => 0,
		datetime => $c->datetime });
	    if($create_results){
		$c->redirect("/wiki/".$create_results->title);
	    }
	    else{
		$c->redirect("/");
	    }
	}
	else{
	    return $c->render('wiki_check.tx', {
		req_title => $c->req->param('wiki_title'),
		req_honbun => $c->req->param('wiki_honbun'),
			      });
	}
    }
};

any '/wiki_list/' => sub {
    my ($c) = @_;
    return $c->redirect('/');
};

any '/wiki_setting' => sub {
    my ($c) = @_;
    return $c->redirect('/');
};

1;
