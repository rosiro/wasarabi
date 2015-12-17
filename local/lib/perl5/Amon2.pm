package Amon2;
use strict;
use warnings;
use 5.008001;
use Amon2::Util ();
use Plack::Util ();
use Carp ();
use Amon2::Config::Simple;
use Amon2::ContextGuard;

our $VERSION = '6.12';
{
    our $CONTEXT; # You can localize this variable in your application.
    sub context { $CONTEXT }
    sub set_context { $CONTEXT = $_[1] }
    sub context_guard {
        Amon2::ContextGuard->new($_[0], \$CONTEXT);
    }
}

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;
    bless { %args }, $class;
}

# For CLI.
sub bootstrap {
    my $class = shift;
    my $self = $class->new(@_);
    $class->set_context($self);
    return $self;
}

# Class method.
sub base_dir {
    my $proto = ref $_[0] || $_[0];
    my $base_dir = Amon2::Util::base_dir($proto);
    Amon2::Util::add_method($proto, 'base_dir', sub { $base_dir });
    $base_dir;
}

sub load_config { Amon2::Config::Simple->load(shift) }
sub config {
    my $class = shift;
       $class = ref $class || $class;
    die "Do not call Amon2->config() directly." if __PACKAGE__ eq $class;
    no strict 'refs';
    my $config = $class->load_config();
    *{"$class\::config"} = sub { $config }; # Class cache.
    return $config;
}

sub mode_name { $ENV{PLACK_ENV} }

sub debug_mode { $ENV{AMON2_DEBUG} ? 1 : 0 }

sub add_config {
    my ($class, $key, $hash) = @_; $hash or Carp::croak("missing args: \$hash");
    Carp::cluck("Amon2->add_config() method was deprecated.");

    # This method will be deprecated.
    $class->config->{$key} = +{
        %{$class->config->{$key} || +{}},
        %{$hash},
    };
}

# -------------------------------------------------------------------------
# Pluggable things.

sub load_plugins {
    my ($class, @args) = @_;
    while (@args) {
        my $module = shift @args;
        my $conf   = @args>0 && ref($args[0]) eq 'HASH' ? shift @args : undef;
        $class->load_plugin($module, $conf);
    }
}

sub load_plugin {
    my ($class, $module, $conf) = @_;
    $module = Plack::Util::load_class($module, 'Amon2::Plugin');
    $module->init($class, $conf);
}

# -------------------------------------------------------------------------
# Local context maker.

sub make_local_context {
    my $class = shift;

    ## Mo critic.
    eval sprintf(q{
        package %s;

        sub context     { $%s::CONTEXT }

        sub set_context { $%s::CONTEXT = $_[1] }

        sub context_guard {
            Amon2::ContextGuard->new($_[0], \$%s::CONTEXT);
        }
    }, $class, $class, $class, $class);
    die $@ if $@;
}

1;
__END__

=encoding utf-8

=head1 NAME

Amon2 - lightweight web application framework

=head1 SYNOPSIS

    package MyApp;
    use parent qw/Amon2/;
    use Amon2::Config::Simple;
    sub load_config { Amon2::Config::Simple->load(shift) }

=head1 DESCRIPTION

Amon2 is simple, readable, extensible, B<STABLE>, B<FAST> web application framework based on L<Plack>.

=head1 METHODS

=head2 CLASS METHODS for C<< Amon2 >> class

=over 4

=item my $c = MyApp->context();

Get the context object.

=item MyApp->set_context($c)

Set your context object(INTERNAL USE ONLY).

=back

=head1 CLASS METHODS for inherited class

=over 4

=item C<< MyApp->config() >>

This method returns configuration information. It is generated by C<< MyApp->load_config() >>.

=item C<< MyApp->mode_name() >>

This is a mode name for Amon2. The default implementation of this method is:

    sub mode_name { $ENV{PLACK_ENV} }

You can override this method if you want to determine the mode by other method.

=item C<< MyApp->new() >>

Create new context object.

=item C<< MyApp->bootstrap() >>

    my $c = MyApp->bootstrap();

Create new context object and set it to global context. When you are writing CLI script, setup the global context object by this method.

=item C<< MyApp->base_dir() >>

This method returns the application base directory.

=item C<< MyApp->load_plugin($module_name[, \%config]) >>

This method loads the plugin for the application.

I<$module_name> package name of the plugin. You can write it as two form like L<DBIx::Class>:

    __PACKAGE__->load_plugin("Web::CSRFDefender");    # => loads Amon2::Plugin::Web::CSRFDefender

If you want to load a plugin in your own name space, use the '+' character before a package name, like following:
    __PACKAGE__->load_plugin("+MyApp::Plugin::Foo"); # => loads MyApp::Plugin::Foo

=item C<< MyApp->load_plugins($module_name[, \%config ], ...) >>

Load multiple plugins at one time.

If you want to load a plugin in your own name space, use the '+' character before a package name like following:

    __PACKAGE__->load_plugins("+MyApp::Plugin::Foo"); # => loads MyApp::Plugin::Foo

=item C<< MyApp->load_config() >>

You can get a configuration hashref from C<< config/$ENV{PLACK_ENV}.pl >>. You can override this method for customizing configuration loading method.

=item C<< MyApp->add_config() >>

DEPRECATED.

=item C<< MyApp->debug_mode() >>

B<((EXPERIMENTAL))>

This method returns a boolean value. It returns true when $ENV{AMON2_DEBUG} is true value, false otherwise.

You can override this method if you need.

=back

=head1 PROJECT LOCAL MODE

B<THIS MODE IS HIGHLY EXPERIMENTAL>

Normally, Amon2's context is stored in a global variable.

This module makes the context to project local.

It means, normally context class using Amon2 use C<$Amon2::CONTEXT> in each project, but context class using L</PROJECT LOCAL MODE> use C<$MyApp::CONTEXT>.

B<<< It means you can't use code depend C<<Amon2->context>> and C<<Amon2->context>> under this mode. >>>>

=head2 NOTES ABOUT create_request

Older L<Amon2::Web::Request> has only 1 argument like following, it uses C<< Amon2->context >> to get encoding:

    sub create_request {
        my ($class, $env) = @_;
        Amon2::Web::Request->new($env);
    }

If you want to use L</PROJECT LOCAL MODE>, you need to pass class name of context class, as following:

    sub create_request {
        my ($class, $env) = @_;
        Amon2::Web::Request->new($env, $class);
    }

=head2 HOW DO I ENABLE PROJECT LOCAL MODE?

C< MyApp->make_local_context() > turns on the project local mode.

There is no way to revert it, thanks.

=head2 METHODS

This module inserts 3 methods to your context class.

=over 4

=item MyApp->context()

Shorthand for $MyApp::CONTEXT

=item MyApp->set_context($context)

It's the same as:

    $MyApp::CONTEXT = $context

=item my $guard = MyApp->context_guard()

Create new context guard class.

It's the same as:

    Amon2::ContextGuard->new(shift, \$MyApp::CONTEXT);

=back

=head1 DOCUMENTS

More complicated documents are available on L<http://amon.64p.org/>

=head1 SUPPORTS

#amon at irc.perl.org is also available.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 CONTRIBUTORS

=over 4

=item noblejasper

=item hiratara

=item s-aska

=item Kentaro Kuribayashi

=item Yuki Ibe

=item mattn

=item Masahiro Nagano

=item rightgo09

=item karupanerura

=item hatyuki

=item Keiji, Yoshimi

=item Nishibayashi Takuji

=item dragon3

=item Fuji, Goro

=item issm

=item hisaichi5518

=item Adrian

=item Fuji, Goro

=item ITO Nobuaki

=item Geraud CONTINSOUZAS

=item Syohei YOSHIDA

=item magnolia

=item Katsuhiro Konishi

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.