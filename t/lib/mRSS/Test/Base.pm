package mRSS::Test::Base;

use strict;
use warnings;

use File::Temp;

sub new {
	my $invocant = shift;
	my $class    = ref($invocant) || $invocant;  # Object or class name
	my $self     = { };
	bless($self, $class);
	return $self;
}

sub setup_cfg {
	my $self = shift;
	if(!defined($self->{_db})) {
		die "Need to call setup_db first.";
	}
	my $dbcfg = File::Temp->new( UNLINK => 1, SUFFIX=>'.conf');
	my $conf = <<"HERE";
schema_class mRSS::Schema

lib lib/mRSS

 
# connection string
<connect_info>
  dsn     dbi:SQLite:dbname=$self->{_db}
  user    
  pass    
</connect_info>
 
# dbic loader options
<loader_options>
  components  InflateColumn::DateTime 
  components  InflateColumn::DateTime::Duration
  components  TimeStamp
</loader_options>

HERE
	print $dbcfg $conf;
	$dbcfg->flush;
	$ENV{DB_CFG_FILE} = $dbcfg->filename;
	$self->{_dbcfg} = $dbcfg;
}

sub setup_db {
	my $self = shift;
	my $db = File::Temp->new( UNLINK => 1, SUFFIX=>'.db');
	my $results = system("sqlite3 $db < sql/tables.sqlite.sql");
	my $exit_status = $results << 8;
	if ($exit_status != 0) {
		die "Could not setup database.  $@";
	}
	$self->{_db} = $db;
}

sub import_data {
	my $self = shift;
	my $feed = shift // 't/import.xml';
	my $results = system("export DB_CFG_FILE=$self->{_dbcfg}; perl bin/import.pl $feed");
	my $exit_status = $results << 8;
	if ($exit_status != 0) {
		die "Could not import data";
	}	
	$self->set_test_file('t/rss20.xml');
}

sub set_test_file {
	my $self = shift;
	my $file = shift;
	$ENV{TEST_FILE} = $file;
}

1;
