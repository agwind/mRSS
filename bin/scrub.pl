#!/usr/bin/perl

use strict;
use warnings;
use v5.010;

use lib 'lib';
use Config::Any;
use Data::Dumper;
use mRSS::Feed;
use mRSS::Scrub;

use Dancer ':script';

use mRSS::ObjStorage;

$mRSS::ObjStorage::conf = $ENV{DB_CFG_FILE} // config->{db_cfg_file};

my $iter = mRSS::Article->_rs->search({ read => 0});

while (my $rs = $iter->next) {
	print $rs->id, ' ', $rs->title,"\n";
	$rs->orig_description($rs->description);
	$rs->description(mRSS::Scrub->scrub($rs->orig_description));
	$rs->update;
}
