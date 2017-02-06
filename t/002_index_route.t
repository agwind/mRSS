use strict;
use warnings;
use Test::More;

#use lib qw{lib t/lib};
use Data::Printer;

# the order is important
use Dancer qw/:tests/;
use mRSS::App;
use Dancer::Test;
#use mRSS::Test::Base;

#my $t = mRSS::Test::Base->new();

#$t->setup_db;
#$t->setup_cfg;
#$t->import_data;


route_exists [GET => '/'], 'a route handler is defined for /';
route_exists [GET => '/login'], 'a route handler is defined for /login';
my $resp = dancer_response GET => '/';
my $logs = read_logs;
diag(p $resp);
foreach my $log (@$logs) {
	diag(p $log);
}
my $content = $resp->content;
my $content2;
while (my $line = <$content>) {
	$content2 .= $line;
}
diag($content2);

response_status_is $resp => 200, 'response status is 200 for /';
done_testing();
