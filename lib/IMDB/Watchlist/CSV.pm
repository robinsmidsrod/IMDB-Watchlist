#!perl

package IMDB::Watchlist::CSV;
use Moose;

use Text::CSV;

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
    my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });
    open my $fh, "<", $self->file or die("Can't open " . $self->file . ": $!\n");
    binmode $fh;
    # Try to autodetect separator from header line
    $csv->header($fh, { sep_set => [ ";", ",", "|", "\t" ], detect_bom => 1, munge_column_names => "lc" });
    # Fetch IMDB ID from "Const" column
    my @imdb_ids = ();
    while ( my $row = $csv->getline_hr($fh) ) {
        my $imdb_id = $row->{'const'};
        next unless defined $imdb_id;
        next unless length $imdb_id;
        next unless $imdb_id =~ m/^tt[0-9]+$/;
        push @imdb_ids, $imdb_id;
    }
    close($fh);
    return \@imdb_ids;
}

no Moose;
__PACKAGE__->meta->make_immutable();
1;
