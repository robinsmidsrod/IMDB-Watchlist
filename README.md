#### DESCRIPTION

IMDB-Watchlist is a simple tool to find IMDB links in an RSS feed. The specific IMDB links should be filtered from a specific
IMDB watchlist so you only get the items in the feed that match entries in the watchlist.

#### INSTALLATION

Install the `cpanm` tool and CPAN dependencies:

    $ cpan App::cpanminus   # or any other method that makes sense
    $ cpanm --installdeps . # uses cpanfile

#### CONFIGURATION


#### TESTING

To run the test suite you use tried-and-true `prove` tool.

    $ prove                  # run entire test suite
    $ prove -v t/002_blobs.t # run a single test in verbose mode

It is also possible to run the test suite and generate code coverage statistics.

    $ PERL5OPT=-MDevel::Cover prove && cover

Open the file `cover_db/coverage.html` in a browser to inspect the details.

#### USAGE

