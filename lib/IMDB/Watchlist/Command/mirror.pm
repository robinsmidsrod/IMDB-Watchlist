#!perl

use strict;
use warnings;

package IMDB::Watchlist::Command::mirror;
use IMDB::Watchlist -command;
use LWP::UserAgent;

# ABSTRACT: Download RSS feeds

sub description { "Download RSS feeds to data directory" }

sub execute {
    my ($self, $opt, $args) = @_;

    my $data_dir = $self->app->config->data_dir;
    if ( ! -d $data_dir ) {
        print "Creating data directory '$data_dir'...\n";
        mkdir $data_dir
            or $self->usage_error("Unable to create data directory '$data_dir'");
    }

    my $ua = LWP::UserAgent->new(
        'agent' => "IMDB::Watchlist/${IMDB::Watchlist::VERSION}" # Avoid error code 1010 from Cloudflare (banned user-agent)
    );

    {
        my $watchlist_url = $self->app->config->watchlist_url;
        my $watchlist_file = $self->app->config->watchlist_file;
        #print "Mirroring $watchlist_url to '$watchlist_file'...\n";
        my $res = $ua->mirror($watchlist_url, $watchlist_file);
        if ( ! $res->is_success ) {
            print "Mirroring $watchlist_url caused HTTP error " . $res->status_line . "\n";
            print $res->as_string . "\n";
        }
    }

    {
        my $feed_url = $self->app->config->feed_url;
        my $feed_file = $self->app->config->feed_file;
        #print "Mirroring $feed_url to '$feed_file'...\n";
        my $res = $ua->mirror($feed_url, $feed_file);
        if ( ! $res->is_success ) {
            print "Mirroring $feed_url caused HTTP error: " . $res->status_line . "\n";
            print $res->as_string . "\n";
        }
    }
}

1;
