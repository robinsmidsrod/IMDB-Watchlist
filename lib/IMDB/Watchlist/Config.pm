#!perl

use strict;
use warnings;

package IMDB::Watchlist::Config;
use Moo;

use Config::Tiny;

has 'is_testing' => (
    is => 'lazy',
);

sub _build_is_testing {
    my ($self) = @_;
    return $ENV{'HARNESS_ACTIVE'} ? 1 : 0;
}

has 'config_file' => (
    is => 'lazy',
);

sub _build_config_file {
    my ($self) = @_;
    # Try to use environment variable if set
    my $config_file = $ENV{'IMDB_WATCHLIST_CONFIG'};
    return $config_file if $config_file;
    # Use different config when running under a test harness, like prove
    return 't/etc/imdb-watchlist.ini' if $self->is_testing;
    # Normal configuration
    return 'etc/imdb-watchlist.ini';
}

has 'config_hash' => (
    is => 'lazy',
);

sub _build_config_hash {
    my ($self) = @_;
    return Config::Tiny->read( $self->config_file )->{_};
}

sub get {
    my ($self, $key) = @_;
    confess("Please specify a config key") unless $key;
    return $self->config_hash->{$key};
}

sub data_dir {
    my ($self) = @_;
    my $data_dir = $ENV{'IMDB_WATCHLIST_DATA_DIR'}
                || $self->get('data_dir');
    return $data_dir if defined $data_dir and length $data_dir;
    return "data";
}

sub imdb_user_id {
    my ($self) = @_;
    return $self->get('imdb_user_id');
}

sub watchlist_url {
    my ($self) = @_;
    return $self->get('watchlist_url')
        || "http://rss.imdb.com/user/" . $self->imdb_user_id . "/watchlist";
}

sub feed_url {
    my ($self) = @_;
    return $self->get('feed_url');
}

sub watchlist_file {
    my ($self) = @_;
    return $self->get('watchlist_file')
        || $self->data_dir . "/watchlist.csv";
}

sub feed_file {
    my ($self) = @_;
    return $self->get('feed_file')
        || $self->data_dir . "/feed.xml";
}

no Moo;
1;
