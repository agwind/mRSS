package mRSS::Repo;

use Moose;

with 'PONAPI::Repository';

use PONAPI::Constants;
use PONAPI::Exception;

use mRSS::Feed;
use mRSS::Article;

my %types = (
	feeds => 1,
	articles => 1,
);

my %relationships = (
    feeds => {
        articles => {
            type          => 'articles',
            one_to_many   => 1,
            #rel_table     => 'rel_articles_comments',
            #id_column     => 'id_articles',
            #rel_id_column => 'id_comments',
        },
    },
);

sub has_type {
	my ($self, $type) = @_;
	return 1 if $types{$type};
}

sub has_relationship {
	my ( $self, $type, $rel_name ) = @_;
	return 1
	if exists $relationships{$type}
		&& exists $relationships{$type}{$rel_name};
}

sub has_one_to_many_relationship {
	my ( $self, $type, $rel_name ) = @_;
	return unless $self->has_relationship($type, $rel_name);
	return 1 if $relationships{$type}{$rel_name}{one_to_many};
}

my %columns = (
	feeds => [qw/ id name url update_interval last_retrieved enabled n_retrieved created/],
	articles => [qw/ id feed title link description orig_description issued modified read favorite imported read_date/],
);

sub type_has_fields {
	my ($self, $type, $has_fields) = @_;
	return unless $self->has_type($type);

	my %type_columns = map +($_=>1), @{ $columns{$type} };
	return if grep !exists $type_columns{$_}, @$has_fields;
	return 1;
}



sub _add_relationships {
}

sub retrieve_all {
	my ($self, %args) = @_;
	my $type     = $args{type};
	my $document = $args{document};

	if ($type eq 'feeds' ) {
		my @feeds = mRSS::Feeds->list();
		foreach my $feed (@feeds) {
			my $resource = $document->add_resource( type => $type, id => $feed->id);
			foreach my $col (@{$columns{$type}}) {
				$resource->add_attribute( $col => $feed->$col );
				$resource->add_self_link();
				$self->_add_relationships( %args, resource => $resource );
			}
		}
	} else {
		die "Not implemented.";
	}
	return;
}
