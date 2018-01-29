#!perl

use strict;
use warnings;

package IMDB::Watchlist;
use App::Cmd::Setup -app;

use IMDB::Watchlist::Config;

our $VERSION = "1.0";

sub config {
    my $app = shift;
    $app->{'config'} ||= IMDB::Watchlist::Config->new();
}

1;
