package wasarabi::DB::Schema;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Teng::Schema::Declare;

base_row_class 'wasarabi::DB::Row';

table {
    name 'revision';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'pagetext', type => 12},
        {name => 'user_id', type => 4},
        {name => 'lastupdate_datetime', type => 11},
    );
    inflate qr/lastupdate_datetime/ => sub {
        my ($col_value) = shift;
        return Time::Piece->strptime($col_value,'%Y-%m-%d %H:%M:%S');
    };
    deflate qr/lastupdate_datetime/ => sub {
        my ($col_value) = shift;
        return $col_value->ymd.' '.$col_value->hms;
    };
};

table {
    name 'user';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'mailaddress', type => 12},
        {name => 'password', type => 12},
        {name => 'display_name', type => 12},
        {name => 'lastlogin_datetime', type => 11},
        {name => 'register_datetime', type => 11},
    );
    inflate qr/.*?_datetime/ => sub {
        my ($col_value) = shift;
        return Time::Piece->strptime($col_value,'%Y-%m-%d %H:%M:%S');
    };
    deflate qr/.*?_datetime/ => sub {
        my ($col_value) = shift;
        return $col_value->ymd.' '.$col_value->hms;
    };
};

table {
    name 'wiki';
    pk 'id';
    columns (
        {name => 'id', type => 4},
        {name => 'title', type => 12},
        {name => 'revision_id', type => 4},
        {name => 'lastupdate_datetime', type => 11},
    );
    inflate qr/lastupdate_datetime/ => sub {
        my ($col_value) = shift;
        return Time::Piece->strptime($col_value,'%Y-%m-%d %H:%M:%S');
    };
    deflate qr/lastupdate_datetime/ => sub {
        my ($col_value) = shift;
        return $col_value->ymd.' '.$col_value->hms;
    };
};

1;
