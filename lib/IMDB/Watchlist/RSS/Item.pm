#!perl

package IMDB::Watchlist::RSS::Item;
use XML::Rabbit;
use URI;
use DateTime::Format::ISO8601;
use DateTime;

has_xpath_value 'title'        => './title';
has_xpath_value 'description'  => './description';
has_xpath_value 'link'         => './link';
has_xpath_value 'url'          => './url';

has_xpath_value 'id'           => './guid';
has_xpath_value 'published_at' => './pubDate';
has_xpath_value 'added_at'     => './added';
has_xpath_value 'category'     => './category';
has_xpath_value 'size'         => './size';
has_xpath_value 'speed'        => './speed';
has_xpath_value 'status'       => './status';

has 'imdb_id' => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

sub _build_imdb_id {
    my ($self) = @_;
    return "" unless $self->link;
    my $url = URI->new($self->link);
    return "" if index($url->host, 'imdb.com') == -1;
    my @path_items = split qr{/}, $url->path;
    my $id = $path_items[-1];
    return "" unless index($id, 'tt') == 0;
    return $id;
}

has 'added_at_datetime' => (
    is         => 'ro',
    isa        => 'DateTime',
    lazy_build => 1,
);

sub _build_added_at_datetime {
    my ($self) = @_;
    my $formatter = DateTime::Format::ISO8601->new();
    my $now = DateTime->now( formatter => $formatter );
    $formatter->set_base_datetime( object => $now );
    my $str = $self->added_at =~ s/^[^\d]*(.*)\s(.*)$/$1T$2/r; # Strip everything before a number
    return $str ? $formatter->parse_datetime( $str ) : $now;
}

finalize_class();
