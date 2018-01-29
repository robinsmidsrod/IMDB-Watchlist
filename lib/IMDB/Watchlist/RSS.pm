#!perl

package IMDB::Watchlist::RSS;
use XML::Rabbit::Root;

has_xpath_value 'version'      => '/rss/@version';

has_xpath_value 'link'         => '/rss/channel/link';
has_xpath_value 'title'        => '/rss/channel/title';
has_xpath_value 'description'  => '/rss/channel/description';

has_xpath_value 'published_at' => '/rss/channel/pubDate';
has_xpath_value 'updated_at'   => '/rss/channel/lastBuildDate';

has_xpath_value 'webmaster'    => '/rss/channel/webMaster';
has_xpath_value 'copyright'    => '/rss/channel/copyright';
has_xpath_value 'language'     => '/rss/channel/language';

has_xpath_object_list 'items'  => '/rss/channel/item' => 'IMDB::Watchlist::RSS::Item',
    handles => {
        'all_items' => 'elements',
    };

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
    return [
        grep { length }
        grep { defined }
        map { $_->imdb_id }
        $self->all_items
    ];
}

finalize_class();
