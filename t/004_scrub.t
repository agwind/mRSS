use Test::Most tests => 11, 'die';
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
use_ok 'mRSS::Scrub';

my $dirty = <<'DIRTY';
<html>
<script> var foo = 1;</script>
<big>small</big>
<div style="color: red; background: red;" class="troll">
BOOM
</div>
</html>
DIRTY

my $clean = <<'CLEAN';
<html>

small
<div class="troll">
BOOM
</div>
</html>
CLEAN

cmp_ok( $clean, 'eq', mRSS::Scrub->scrub($dirty));

my $feed = mRSS::Feed->find( { name => 'feed1' } );
isa_ok($feed, 'mRSS::Feed', 'find returns a feed');

$t->set_test_file('t/rss_scrub.xml');

is($feed->retrieve, 1, 'Items in our test file');

my $article = mRSS::Article->find({title => 'Test'});
isa_ok($article, 'mRSS::Article', 'find returns an article');

is($article->orig_description, '<div style="color: white; background: white">BOOM</div>', 'Original description is populated');
is($article->description, '<div>BOOM</div>', 'Scrubbed description is populated');

