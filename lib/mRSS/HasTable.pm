package mRSS::HasTable;
use Moose::Role;

has table => (
	is  => 'rw',
	isa => 'Str',
);

package Moose::Meta::Class::Custom::Trait::HasTable;
sub register_implementation { 'mRSS::HasTable' }

1;
