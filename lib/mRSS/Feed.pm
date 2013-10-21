#!/usr/bin/perl

package mRSS::Feed;

use Config::Any;
use HTTP::Tiny;
use XML::Feed;
use Moose -traits => 'mRSS::HasTable';
use mRSS::MooseTable;
use mRSS::Schema;
use mRSS::Article;
use Carp qw/cluck/;

our $schema;

extends 'mRSS::ObjStorage';

__PACKAGE__->meta->table('Feed');
	
has_column 'name';

has_column 'url';

has_column 'update_interval';

has_column 'last_retrieved' => (
	is => 'res',
	isa => 'DateTime',
);

has_column 'id' => (
	is => 'res',
);

has_column 'enabled' => (
	default => '1',
);

has_column 'n_retrieved' => (
	default => 0,
);

has_column 'created' => (
	isa => 'DateTime',
	default => sub { return DateTime->now() },
);

has '__empty_shell__' => (
	is => 'rw',
);

no mRSS::Feed;

sub list {
	my $self = shift;
	my $criteria = shift;
	my $options = shift;
	if (!defined($criteria)) {
		$criteria = { enabled => 1 };
	}
	if (ref($criteria) ne 'HASH') {
		die "Argument needs to be a hash ref"
	}
	if (!defined($options)) {
		$options = {
			order_by => { -desc => 'name' },
		};
	}

	my $iter = $self->_rs->search($criteria,$options);
	my @feeds;
	while (my $row = $iter->next) {
		my $obj = $self->_inflate($row);
		push @feeds, $obj;
	}
	return @feeds;
}

sub articles {
	my $self = shift;
	my $criteria = shift;
	my $options = shift;
	if (!defined($criteria)) {
		$criteria = { read => 0 };
	}
	if (ref($criteria) ne 'HASH') {
		die "Argument needs to be a hash ref"
	}
	if (!defined($options)) {
		$options = {
			order_by => { -desc => 'issued' },
		};
	}
	my $iter = $self->{_row}->articles->search($criteria,$options);
	my @articles;
	while (my $row = $iter->next) {
		my $obj = mRSS::Article->_inflate($row);
		push @articles, $obj;
	}
	return @articles;
}

sub count {
	my $self = shift;
	return $self->{_row}->articles->count();
}

sub unread {
	my $self = shift;
	return $self->{_row}->articles->count({ read => 0 });
}

sub _get_feed {
	my $self = shift;
	my $feed;
	if($ENV{TEST_FILE}) {
		if (-f $ENV{TEST_FILE} ) {
			open(my $fh, '<', $ENV{TEST_FILE}) or die $!;
			$feed = do { local $/; <$fh> };
			close $fh;
		} else  {
			die "Can't read file: $ENV{TEST_FILE}";
		}
	} else {
		my $response = HTTP::Tiny->new( timeout => 8 )->get($self->url);
		return unless $response->{success};
		$feed = $response->{content};
	}
	return $feed;
}

sub retrieve {
	my $self = shift;
	my $feed = $self->_get_feed;
	return if !defined($feed);
	my $count = 0;
	$feed = XML::Feed->parse(\$feed);
	foreach my $item ($feed->items) {
		my $article;
		eval {
			if(defined($item->title) && defined($item->link)) {
				$article = mRSS::Article->find({ feed => $self->id, title => $item->title, link => $item->link });
			}
		};
		if(!defined($article)) {
			my $article_hash = {
				feed => $self,
				title => $item->title,
				link => $item->link,
				description => $item->content->body,
			};
			if($item->modified) {
				$article_hash->{modified} = $item->modified;
			}
			if($item->issued) {
				$article_hash->{issued} = $item->issued;
			}
			eval {
				$article = mRSS::Article->new($article_hash);
			};
			if($article) {
				$count++;
			}
		}
	}
	$self->n_retrieved($self->n_retrieved + 1);
	$self->mark_retrieved();
	return $count;
}

sub mark_retrieved {
	my $self = shift;
	$self->{_row}->last_retrieved(DateTime->now());
	$self->{_row}->update->discard_changes();
	$self->__last_retrieved($self->{_row}->last_retrieved);
}

1;
