#!/usr/bin/perl

use strict;
use warnings;
use v5.010;

use lib 'lib';
use Config::Any;
use Data::Dumper;
use mRSS::Feed;

use Dancer ':script';

use mRSS::ObjStorage;

$mRSS::ObjStorage::conf = $ENV{DB_CFG_FILE} // config->{db_cfg_file};

my @feeds = mRSS::Feed->list;
foreach my $feed (sort { $a->name cmp $b->name } @feeds) {
	print $feed->name;
	my $num = $feed->retrieve;
	print ": $num\n";
}
