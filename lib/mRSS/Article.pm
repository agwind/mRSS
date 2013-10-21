package mRSS::Article;

use Moose -traits => 'mRSS::HasTable';
use mRSS::MooseTable;
use mRSS::Schema;
use DateTime;
use Moose::Util::TypeConstraints;
use mRSS::Feed;

our $schema;

extends 'mRSS::ObjStorage';

__PACKAGE__->meta->table('Article');

has_column 'id' => (
	is => 'res',
);

coerce 'mRSS::Feed'
	=> 'Int'
		=> via { mRSS::Feed->find( $_ ) };

subtype 'mRSSFeedResult',
	as 'mRSS::Schema::Result::Feed';

coerce 'mRSS::Feed'
	=> from 'mRSS::Schema::Result::Feed'
		=> via { mRSS::Feed->_inflate( $_ ) };

has_column 'feed' => (
	isa => 'mRSS::Feed',
	coerce => 1,
);

has_column 'title';

has_column 'link';

has_column 'description';

has_column 'issued' => (
	isa => 'DateTime',
);

has_column 'modified' => (
	isa => 'DateTime',
);

has_column 'read' => (
	traits => ['Bool'],
	isa => 'Bool',
	default => 0,
	trigger => \&_set_read,
);

has_column 'favorite' => (
	traits => ['Bool'],
	isa => 'Bool',
	default => 0,
);

has_column 'imported' => (
	isa => 'DateTime',
	default => sub { return DateTime->now() },
);

has_column 'read_date' => (
	isa => 'DateTime',
);

has '__empty_shell__' => (
	is => 'rw',
);

no mRSS::Article;

sub _set_read {
   my ( $self, $read, $old_read ) = @_;
	if (! $self->__empty_shell__) {
		if($read) {
			$self->read_date(DateTime->now());
		}
	}
}

1;
