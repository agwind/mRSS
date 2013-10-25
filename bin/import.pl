#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

use lib 'lib';

use XML::Smart;
use Config::Any;
use mRSS::Feed;
use DateTime::Duration;

use Dancer ':script';

use mRSS::ObjStorage;

$mRSS::ObjStorage::conf = $ENV{DB_CFG_FILE} // config->{db_cfg_file};

my $file = $ARGV[0];

if (! -f "$file" ) {
	die "Not a file.  Usage ./import <file.xml>";
}

my $xml = XML::Smart->new($file);


#print Data::Dumper->Dump([$xml]);

foreach my $outline (@{$xml->{opml}->{body}->{outline}}) {
	print $outline->{text},"***\n";
	eval {
		my $sub = mRSS::Feed->new(
				name => "$outline->{text}",
				url => "$outline->{xmlUrl}",
				update_interval => DateTime::Duration->new( hours => 2),
		);
	};
	if($@) {
		print $@,"\n";
	}
}
