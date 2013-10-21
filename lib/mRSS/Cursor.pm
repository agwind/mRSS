#!/usr/bin/perl

package mRSS::Cursor;

use Moose -traits => 'mRSS::HasTable';
use mRSS::MooseTable;
use mRSS::Schema;
use Carp qw/cluck/;

our $schema;

has feed => (
	isa => 'mRSS::Feed',
	is => 'rw',
);

has 'options' => (
	is => 'rw',
);

has 'criteria' => (
	is => 'rw',
);

has 'length' => (
	is => 'rw',
);

has 'index' => (
	is => 'rw',
	traits => ['Hash'],
	isa => 'HashRef',
	default => sub { return {}; },
);

has 'items' => (
	is => 'rw',
	traits => ['Array'],
	isa => 'ArrayRef',
	default => sub { return []; },
);

no mRSS::Cursor;

sub BUILD {
	my $self = shift;
	#Need for speed.
	#my @articles = $self->feed->listArticles( $self->criteria, $self->options );
	my $rs = $self->feed->{_row}->search_related( 'articles',  $self->criteria, $self->options);
	my $count = 0;
	while (my $row = $rs->next) {
		$self->items->[$count] = $row->id;
		$self->index->{$row->id} = $count;
		$count++;
	}
	$self->length($count);
}

sub flatten {
	my $self = shift;
	my $hash;
	$hash->{length} = $self->length;
	$hash->{index} = $self->index;
	$hash->{items} = $self->items;
	return $hash;
}

sub item {
	my $self = shift;
	my $pos = shift;
	return $self->items->[$pos];
}

sub position {
	my $self = shift;
	my $article_id = shift;
	return $self->index->{$article_id};
}

1;
