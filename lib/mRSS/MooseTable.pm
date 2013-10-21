package mRSS::MooseTable;

use Moose -traits => 'mRSS::HasTable';
use Moose::Exporter;
use MooseX::StrictConstructor;

use strict;

Moose::Exporter->setup_import_methods(
	with_meta => [ 'has_column' ],
	also => 'Moose',
);

sub has_column {
	my ($meta, $name, %options ) = @_;
	my %attribute_hash;
	my $is_restricted;
	if(defined($options{is}) && $options{is} eq 'res') {
		delete $options{is};
		$is_restricted = 1;
	}
	my $aname = "__$name";
	$meta->add_attribute(
		$aname,
		accessor => $aname,
		%options
	);
	if($is_restricted) {
		$meta->add_method(
			$name => sub {
				my $self = shift;
				my @args = @_;
				if(@args) {
					die "Restricted column $name";
				} else {
					return $self->$aname;
				}
			},
			"_$name" => sub {
				my $self = shift;
				my @args = @_;
				if(@args) {
					$self->$aname(@args);
					$self->{_row}->($name)(@args);
					$self->{_row}->update;
				} else {
					return $self->$aname;
				}
			}
		);
	} else {
		$meta->add_method(
			$name => sub {
				my $self = shift;
				my @args = @_;
				if(@args) {
					$self->$aname(@args);
					$self->{_row}->$name(@args);
					$self->{_row}->update;
				} else {
					return $self->$aname;
				}
			}
		);
	}
}

1;
