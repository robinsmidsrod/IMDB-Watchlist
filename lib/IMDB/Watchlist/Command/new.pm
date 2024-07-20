#!perl

use strict;
use warnings;

package IMDB::Watchlist::Command::new;
use IMDB::Watchlist -command;
use IMDB::Watchlist::RSS;
use IMDB::Watchlist::HTML;
use DateTime::Format::ISO8601;
use File::Slurp qw(read_file write_file);

# ABSTRACT: Parse IMDB watchlist and show new items only

sub description { "Parse watchlist HTML file and show new matching entries in feed" }

sub execute {
    my ($self, $opt, $args) = @_;

    my $watchlist_file = $self->app->config->watchlist_html_file;
    if ( ! -r $watchlist_file ) {
        $self->usage_error("$watchlist_file: $!");
    }

    my $wl = IMDB::Watchlist::HTML->new( file => $watchlist_file );
#    print join("|", "CHANNEL", $wl->title, $wl->link) . "\n";
#    foreach my $item ( $wl->all_items ) {
#        print join("|", "ITEM", $item->imdb_id, $item->published_at, $item->title) . "\n";
#    }

    my $ids = join("|", $wl->all_imdb_ids);
    #print "Looking for: $ids\n";
    my $imdb_id_re = qr{($ids)};

    my $feed_file = $self->app->config->feed_file;
    if ( ! -r $feed_file ) {
        $self->usage_error("$feed_file: $!");
    }

    # Fetch when files were last mirrored, or one year in the past if never run
    my $formatter = DateTime::Format::ISO8601->new();
    my $last_run = read_file( $self->app->config->last_run_file );
    my $last_run_dt = $last_run
        ? $formatter->parse_datetime( $last_run )
        : DateTime->new()->subtract( years => 1 );
    
    my $feed = IMDB::Watchlist::RSS->new( file => $feed_file );
    #print "=" x 79, "\n\n";
    foreach my $item ( sort { $b->added_at cmp $a->added_at } $feed->all_items ) {
        next if $item->added_at_datetime < $last_run_dt; # skip items previously handled
        my $is_match = ( $item->description . $item->url ) =~ m{$imdb_id_re} ? 1 : 0;
        print join("\n",
            map { '* ' . $_ }
            map { _trim($_) }
            $item->title,
            $item->link,
            $item->url,
            $item->added_at,
            $item->size,
            $item->status,
        ) . "\n\n" if $is_match;
    }
    #print "=" x 79, "\n\n";
    foreach my $item ( sort { $b->added_at cmp $a->added_at } $feed->all_items ) {
        next if $item->added_at_datetime < $last_run_dt; # skip items previously handled
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
    #print "=" x 79, "\n";

    # Save when the files where last parsed and displayed
    my $now_dt = DateTime->now( formatter => $formatter );
    write_file( $self->app->config->last_run_file, "" . $now_dt);
}

sub _trim {
    my ($str) = @_;
    return unless defined $str;
    $str =~ s/^ \s* (.*?) \s* $/$1/xms;
    return $str;
}

1;
