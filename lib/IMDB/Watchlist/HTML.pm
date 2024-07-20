#!perl

package IMDB::Watchlist::HTML;
use Moose;

use File::Slurp qw(read_file);
use Mojo::DOM;
use JSON qw(decode_json);

has 'file' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'imdb_ids' => (
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    traits     => ['Array'],
    lazy_build => 1,
    handles    => {
        'all_imdb_ids' => 'elements',
    },
);

sub _build_imdb_ids {
    my ($self) = @_;
    my $content = read_file( $self->file );
    my $dom = Mojo::DOM->new($content);
    my $json = $dom->at('script#__NEXT_DATA__')->text;
    my $ds = decode_json($json);

    my $edges = $ds->{'props'}
      ->{'pageProps'}
      ->{'mainColumnData'}
      ->{'predefinedList'}
      ->{'titleListItemSearch'}
      ->{'edges'} // [];

    # Fetch IMDB ID from "listItem/id" column
    my @imdb_ids = ();
    while ( my $item = shift @$edges ) {
        my $imdb_id = $item->{'listItem'}->{'id'};
        next unless defined $imdb_id;
        next unless length $imdb_id;
        next unless $imdb_id =~ m/^tt[0-9]+$/;
        push @imdb_ids, $imdb_id;
    }
    return \@imdb_ids;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
