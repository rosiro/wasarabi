package wasarabi::Model::Wiki;
use 5.10.0;
use strict;
use warnings;
use utf8;
use Data::Printer;

sub validate_wiki {
    my ($self, $c) = @_;
    my $req = $c->{request};
    my $error_title;
    my $error_honbun;
    if($req->param('wiki_title')){
    }
    else{
	$error_title = 'missing';
    }
    if($req->param('wiki_honbun')){
    }
    else{
	$error_honbun = 'missing';
    }
    my %results = (
	title => $error_title,
	honbun => $error_honbun,
	);
    return \%results;
}

sub create {
    my ($self, $c) = @_;

    my $req = $c->{request};
    my $db = $c->{db};
    my $dt = $c->{datetime};
    my $account_id = $c->{account_id};

    p $c;
    
    # INSERT RIVISION
    my $insert_rivision = $db->insert("revision",{
	pagetext => $req->param('wiki_honbun'),
	user_id => $account_id,
	lastupdate_datetime => $dt });
    if($insert_rivision){
	# INSERT WIKI
	my $insert_rivision = $db->insert("wiki",{
	    title => $req->param('wiki_title'),
	    revision_id => $insert_rivision->id,
	    lastupdate_datetime => $dt });
	return $insert_rivision;
    }
    else{
	return 0;
    }
}

sub find {
    my $self = shift;
}

sub load_wiki {
    my ($self, $c) = @_;
    my $db = $c->{db};
    my $title = $c->{title};
    my $find_wiki = $db->lookup('wiki', { 'title' => $title });
    if($find_wiki){
	my $find_revision = $db->lookup('revision', { 'id' => $find_wiki->revision_id });
	if($find_revision){
	    my %wiki = (
		title => $find_wiki->title,
		honbun => $find_revision->pagetext,
		lastupdate_datetime => $find_wiki->lastupdate_datetime,
		);
	    return \%wiki;
	}
	else{
	    return 0;
	}
    }
    else{
	return 0;
    }
}

sub search {
    my ($self, $c) = @_;
    my $db = $c->{db};
    my $page = $c->{page};
    my $sort_query = $c->{sort_key};
    my $rows = $c->{rows};

    my $sql = 'SELECT * FROM wiki';
    if($page){
	my $limit = "";
	$rows = 20 unless($rows);
	if($page == 1){
	    $limit = 0;
	}
	else{
	    if($page > 1){
		$limit = ($page - 1) * $rows;
	    }
	}
	$sql .= ' LIMIT '.$limit.', '.$rows;
    }
    if($sort_query){
	$sql .= ' ORDER BY '.$sort_query;
    }
    else{
	$sql .= ' ORDER BY lastupdate_datetime DESC';
    }
    my @results = $db->search_by_sql($sql);
    return \@results;
}

sub update {
    my $self = shift;
}

sub remove {
    my $self = shift;
}

1;
