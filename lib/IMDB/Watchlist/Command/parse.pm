#!perl

use strict;
use warnings;

package IMDB::Watchlist::Command::parse;
use IMDB::Watchlist -command;
use IMDB::Watchlist::RSS;
use IMDB::Watchlist::CSV;

# ABSTRACT: Parse IMDB watchlist

sub description { "Parse watchlist CSV file and show matching entries in feed" }

sub execute {
    my ($self, $opt, $args) = @_;

    my $watchlist_file = $self->app->config->watchlist_file;
    if ( ! -r $watchlist_file ) {
        $self->usage_error("$watchlist_file: $!");
    }

    my $wl = IMDB::Watchlist::CSV->new( file => $watchlist_file );
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
    print "=" x 79, "\n\n";
    foreach my $item ( sort { $b->added_at cmp $a->added_at } $feed->all_items ) {
        my $is_match = ( $item->description . $item->url ) =~ m{$imdb_id_re} ? 1 : 0;
        print join("\n",
            map { _trim($_) }
            $item->title,
            $item->link,
            $item->url,
            $item->added_at,
            $item->size,
            $item->status,
        ) . "\n\n" if $is_match;
    }
    print "=" x 79, "\n\n";
    foreach my $item ( sort { $b->added_at cmp $a->added_at } $feed->all_items ) {
        my $is_match = ( $item->description . $item->url ) =~ m{$imdb_id_re} ? 1 : 0;
        print join("\n",
            map { _trim($_) }
            $item->title,
            $item->link,
            $item->url,
            $item->added_at,
            $item->size,
            $item->status,
        ) . "\n\n" unless $is_match;
    }
    print "=" x 79, "\n";
}

sub _trim {
    my ($str) = @_;
    return unless defined $str;
    $str =~ s/^ \s* (.*?) \s* $/$1/xms;
    return $str;
}

1;
