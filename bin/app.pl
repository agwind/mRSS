#!/usr/bin/env perl
 
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
 
use mRSS::App;
mRSS::App->to_app;
