#!/usr/bin/env perl
 
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Plack::Builder;
use Plack::App::File;
use WebAPI::DBIC::WebApp;
use Alien::Web::HalBrowser;
use Authen::Passphrase::SaltedSHA512;
use Config::Any;
use Plack::Middleware::CrossOrigin;

my $users = Config::Any->load_files({files => ["$FindBin::Bin/../users.json" ], use_ext => 1});
$users = $users->[0]->{(keys %{$users->[0]})[0]};

my $hal_app = Plack::App::File->new(
  root => Alien::Web::HalBrowser->dir
)->to_app;

my $schema_class = $ENV{WEBAPI_DBIC_SCHEMA}
    or die "WEBAPI_DBIC_SCHEMA env var not set";
eval "require $schema_class" or die "Error loading $schema_class: $@";

my $schema = $schema_class->connect(); # uses DBI_DSN, DBI_USER, DBI_PASS env vars

my $data_api = WebAPI::DBIC::WebApp->new({
    routes => [ map( $schema->source($_), $schema->sources) ]
})->to_psgi_app;

my $dapi_prefix = "/dapi";

use Dancer2::Debugger;
my $debugger = Dancer2::Debugger->new();

use mRSS::App;
my $app = mRSS::App->to_app;

builder {
	#enable 'CrossOrigin', origins => '*', credentials => 1, headers => '*';
	 enable 'CrossOrigin', 
	 	origins => [ 'http://localhost:8080', 'http://localhost:8000',  'http://localhost:3000' ], 
		credentials => 1, 
		headers => [ qw/Cache-Control Depth If-Modified-Since User-Agent X-File-Name X-File-Size X-Prototype-Version X-Requested-With authorization content-type/ ], 
		methods => ['GET', 'POST'];
    enable_if { $_[0]->{REQUEST_URI} ne '/login' } 'Auth::Basic', authenticator => \&authen_cb;
    mount "$dapi_prefix/" => builder {
        mount "/browser" => $hal_app;
        mount "/"        => $data_api;
    };

    $debugger->mount,
    mount '/' => builder {
        $debugger->enable;
        $app;
    }
};


sub authen_cb {
	my($username, $password, $env) = @_;
	return if !defined($users->{$username});

	my $auth = Authen::Passphrase::SaltedSHA512->new(
		salt_hex => $users->{$username}->{salt},
		hash_hex => $users->{$username}->{hash},
	);
	return $auth->match($password);
}
