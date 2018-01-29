#!perl

use strict;
use warnings;

package IMDB::Watchlist::Command::parse;
use IMDB::Watchlist -command;
use IMDB::Watchlist::RSS;

# ABSTRACT: Parse IMDB watchlist

sub description { "Parse watchlist RSS feed and show matching entries in feed" }

sub execute {
    my ($self, $opt, $args) = @_;

    my $watchlist_file = $self->app->config->watchlist_file;
    if ( ! -r $watchlist_file ) {
        $self->usage_error("$watchlist_file: $!");
    }

    my $wl = IMDB::Watchlist::RSS->new( file => $watchlist_file );
#    print join("|", "CHANNEL", $wl->title, $wl->link) . "\n";
#    foreach my $item ( $wl->all_items ) {
#        print join("|", "ITEM", $item->imdb_id, $item->published_at, $item->title) . "\n";
#    }

    my $ids = join("|", $wl->all_imdb_ids);
    my $imdb_id_re = qr{($ids)};

    my $feed_file = $self->app->config->feed_file;
    if ( ! -r $feed_file ) {
        $self->usage_error("$feed_file: $!");
    }

    my $feed = IMDB::Watchlist::RSS->new( file => $feed_file );
    foreach my $item ( $feed->all_items ) {
        print join("\n", $item->title, $item->link, $item->added_at, $item->size, $item->status) . "\n\n"
            if $item->description =~ m{$imdb_id_re};
    }
}

1;
