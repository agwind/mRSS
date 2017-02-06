#!/usr/bin/env perl
 
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Plack::Builder;

use Dancer2::Debugger;
my $debugger = Dancer2::Debugger->new();

use mRSS::App;
my $app = mRSS::App->to_app;

builder {
	$debugger->mount,
	mount '/' => builder {
		$debugger->enable;
		$app;
	}
};
