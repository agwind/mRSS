#!/usr/bin/perl

package mRSS::ObjStorage;

use Config::Any;
use mRSS::MooseTable;
use mRSS::Schema;
use Carp qw/cluck/;

our $schema;
our $conf;

sub BUILD {
	my $self = shift;
	my %hash = $self->_deflate;
	if(!$self->__empty_shell__) {
		$self->{_row} = $self->_rs->create(\%hash);
	}
}

around BUILDARGS => sub {
	my $orig = shift;
	my $class = shift;
	my %args  = ( @_ == 1 ? %{ $_[0] } : @_ );
	foreach my $attr ( $class->meta->get_all_attributes ) {
		my $key = $attr->name;
		$key =~ s/^__//;
		if(exists($args{$key})) {
			$args{'__' . $key} = delete $args{$key};
		}
	}
	return $class->$orig(%args);
};

no mRSS::ObjStorage;

sub _inflate {
	my $self = shift;
	my $row = shift;
	my %hash = $row->get_inflated_columns;
	my $obj = $self->new({ '__empty_shell__' => 1 });
	foreach my $key (keys %hash) {
		if(defined($hash{$key})) {
			my $func = "__$key";
			$obj->$func($hash{$key});
		}
	}
	$obj->{_row} = $row;
	$obj->__empty_shell__(0);
	return $obj;
}

# deflate to hash for dbic
sub _deflate {
   my $self = shift;
   my @columns = $self->_schema->source($self->meta->table)->columns();
   my %hash;
   foreach my $col (@columns) {
      my $aname = "__$col";
      my $value = $self->$aname;
		#FIXME Need to find a non-inflatable accessor
      if(ref($value) && $value->can('__id')) {
         $value = $value->__id;
      }
      my $col_info = $self->_schema->source($self->meta->table)->column_info($col);
      if($col_info->{is_auto_increment} && !defined($value)) { next; }
      $hash{$col} = $value;
   }
   return %hash;
}

sub find {
	my $self = shift;
	#FIXME - findordie
	my $sub =  $self->_rs->find(@_) or die "Not found";
	my $obj = $self->_inflate($sub);
	return $obj;
}

sub _storage {
	my $self = shift;
	if (!defined($self->{_row})) {
		if(!defined($self->{_id})) {
			die "Trying to access an uninstantiated object";
		}
		$self->{_row} = $self->_rs->find($self->{_id});

	}
	return $self->{_row};
}

sub _rs {
	my $self = shift;
	return $self->_schema->resultset($self->meta->table);
}

sub _schema {
	my $self = shift;
	if(!defined($schema)) {
		
		my $cfg = Config::Any->load_files({files =>[$conf],use_ext => 1  }, flatten_to_hash => 1,
		); 

		my $conf = $cfg->[0];
		my $c = (values %$conf)[0];

		my ($dsn, $user, $pass, $options, $extra) =
		map { $c->{connect_info}->{$_} } qw/dsn user pass options extra/;
		$options ||= {};
		$extra ||= {};

		$schema = mRSS::Schema->connect( $dsn, $user, $pass, $options,$extra);

	}
	return $schema;
}

1;
