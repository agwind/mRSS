use Test::Most tests => 52, 'die';
use Test::Deep;
use strict;
use warnings;
use lib qw{lib t/lib};
use mRSS::Test::Base;

my $t = mRSS::Test::Base->new();

$t->setup_db;
$t->setup_cfg;
$t->import_data;

use_ok 'mRSS::ObjStorage';

{ 
	no warnings 'once';
	$mRSS::ObjStorage::conf = $ENV{DB_CFG_FILE};
}

use_ok 'mRSS::Feed';
use_ok 'mRSS::Article';
use_ok 'mRSS::Cursor';

my @feeds = mRSS::Feed->list;

ok(scalar @feeds == 2, 'list returned aray with 2 items');

my $feed = mRSS::Feed->find( { name => 'feed1' } );
isa_ok($feed, 'mRSS::Feed', 'find returns a feed');

my @methods = qw/name url update_interval last_retrieved id enabled n_retrieved created __empty_shell__ list articles count unread retrieve mark_retrieved find/;

can_ok($feed, @methods);

is($feed->name, 'feed1', 'name method');
is($feed->url, 'http://localhost/feed/', 'url method');
isa_ok($feed->update_interval, 'DateTime::Duration');
is($feed->update_interval->in_units('minutes'), 120, 'Right minutes from update_interval');
is($feed->last_retrieved, undef, 'last_retrieved is not set');
is($feed->id, 1, 'id returns the proper id');
is($feed->enabled, 1, 'feeds are enabled by default');
is($feed->n_retrieved, 0, 'number of times we grabbed a feed');
isa_ok($feed->created,'DateTime');
is($feed->count, 0);
is($feed->unread, 0);

is($feed->retrieve, 2, 'Items in our test file');
is($feed->n_retrieved, 1, 'Retrieved the articles 1 time');
is($feed->count, 2, 'Number of articles in the db');
is($feed->unread, 2, 'Number of unread articles in the db');
isa_ok($feed->last_retrieved, 'DateTime',' last_retrieved got updated when we called retrieve()');

@methods = qw/feed options criteria length index items flatten item position/;

my $cursor = mRSS::Cursor->new({ feed => $feed });

is($cursor->length, 2, 'Cursor for 2 items');
isa_ok($cursor->feed, 'mRSS::Feed');

my $index = {
	1 => 0,
	2 => 1,
};

my $items = [
	1,
	2
];

cmp_deeply($cursor->index, $index, 'We got back our article id => position index');
cmp_deeply($cursor->items, $items, 'We got pack a list of our article ids');
is($cursor->item(0), 1, 'Returned the 0th item');
is($cursor->position(2), 1, 'Grab the position of the 2nd article');
cmp_deeply($cursor->flatten, { length => 2, items => $items, index => $index }, 'Cursor can be exported (flatten)');

can_ok($cursor, @methods);

my @articles = sort { $a->id <=> $b->id } $feed->articles;

is(scalar @articles,2, '2 articles returned from ->articles()');

my $article = mRSS::Article->find({title => 'Test'});
isa_ok($article, 'mRSS::Article', 'find returns an article');

@methods = qw/find id feed title link description orig_description issued modified read favorite imported read_date/;

can_ok($article, @methods);

like($article->id, qr/\d+/, 'id method returns a number');
isa_ok($article->feed, 'mRSS::Feed');
is($article->feed->name, 'feed1','We have the correct feed/article relationship');
is($article->title, 'Test', 'Title is populated');
is($article->link, 'http://localhost/weblog/2004/05/test.html', 'Link is populated');
is($article->description, '<p>This is a test.</p>

<p>Why don\'t you come down to our place for a coffee and a <strong>chat</strong>?</p>', 'Description is populated');
is($article->orig_description, '<p>This is a test.</p>

<p>Why don\'t you come down to our place for a coffee and a <strong>chat</strong>?</p>', 'Original description is populated');
isa_ok($article->issued, 'DateTime', 'Got back a DateTime object for issued');
is($article->issued->set_time_zone('UTC')->datetime, '2004-05-09T07:03:28', 'Issued is populated');
is($article->modified, undef, 'Article does not hae modified attribute');
is($article->favorite, 0, 'Is not marked as a favorite');
isa_ok($article->imported, 'DateTime');
is($article->read_date, undef, 'Article doesn\'t have a read date yet');
is($article->read, 0, 'Is not marked as read');
$article->read(1);
is($article->read, 1, 'Article read state is marked as true');
isa_ok($article->read_date, 'DateTime');

#Let's make sure the Moose trigger doesn't affect our constructor and _inflate
my $article_dup = mRSS::Article->find({ title => 'Test'});
is($article_dup->read, 1, 'Our second obj is in the read state that we think it is');
isa_ok($article_dup->read_date, 'DateTime', 'Second obj reaad_date');

