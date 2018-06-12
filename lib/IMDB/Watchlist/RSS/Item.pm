#!perl

package IMDB::Watchlist::RSS::Item;
use XML::Rabbit;
use URI;

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

finalize_class();
