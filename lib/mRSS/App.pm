package mRSS::App;

use Dancer ':syntax';
use Dancer::Plugin::Ajax;
#use Dancer::Plugin::NYTProf;
use Text::Xslate qw/mark_raw/;
use mRSS::ObjStorage;
use mRSS::Feed;
use mRSS::Article;
use mRSS::Cursor;

our $VERSION = '0.1';

$mRSS::ObjStorage::conf = $ENV{DB_CFG_FILE} // config->{db_cfg_file};

#TODO validate all input

hook 'before' => sub {
	if ( !session('user') && request->path_info !~ m{^/login} ) {
		var requested_path => request->path_info;
		request->path_info('/login');
	}
};

get '/' => sub {
	my @feeds = sort {$a->name cmp $b->name } mRSS::Feed->list;
	my $user = session 'user';
	template 'index',	{ feeds => \@feeds, user => $user};
};

get '/logout' => sub {
	session 'user' => undef;
	template 'login', { message => "You have successfully logged out." };
};

get '/login' => sub {
	# Display a login page; the original URL they requested is available as
	# vars->{requested_path}, so could be put in a hidden field in the form
	template 'login', { path => vars->{requested_path}, login_url => uri_for('/login') };
};

get '/subs/:id' => sub {
	my $feed = mRSS::Feed->find( params->{id} );
	my $criteria = { read => 0 };
	my $options = { order_by => { -desc => 'issued' }, rows => 50 };
	my $cursor = mRSS::Cursor->new( feed => $feed, criteria => $criteria, options => $options );
	session $feed->id . '_cursor' => $cursor->flatten;
	my @articles = $feed->articles( $criteria, $options);
	template 'subs', { feed => $feed, articles => \@articles };
};

get '/article/:id' => sub {
	my $article = mRSS::Article->find( params->{id} );
	my $cursor = session $article->feed->id . '_cursor';
	my $pos = $cursor->{index}->{$article->id};
	my ($prev,$next);
	if($pos > 0) {
		$prev = $cursor->{items}->[$pos - 1];
	}
	if($pos < $cursor->{length} -1) {
		$next = $cursor->{items}->[$pos + 1];
	}
	use DateTime::Format::Mail;
	my $issued = DateTime::Format::Mail->format_datetime($article->issued);
	if ($article->read == 0) {
		$article->read(1);
	}
	template 'article', { article => $article, prev => $prev, next => $next, issued => $issued };
};

ajax '/article/:id/read/:read' => sub {
	my $article = mRSS::Article->find( params->{id} );
	eval {
		$article->read(params->{read});
	};
	my $error = 0;
	if ($@) {
		$error = 1;
	}
	return to_json { error => $error };
};

#TODO - consolidate /read/favorite to :action
ajax '/article/:id/favorite/:fav' => sub {
	my $article = mRSS::Article->find( params->{id} );
	eval {
		$article->favorite(params->{fav});
	};
	my $error = 0;
	if ($@) {
		$error = 1;
	}
	return to_json { error => $error };
};

ajax '/subs/:id/refresh' => sub {
	my $sub = mRSS::Feed->find( params->{id} );
	my %return;
	$return{'new'} = $sub->retrieve;
	$return{'count'} = $sub->count;
	$return{'unread'} = $sub->unread;
	return to_json \%return;
};

post '/login' => sub {
	my $user = params->{username};
	if (defined(config->{users}->{$user}) && 
		(config->{users}->{$user} eq params->{password})) {
		session user => $user;
		redirect '/';
		#redirect params->{path} || '/';
	} else {
		redirect '/login?failed=1';
	}
};

true;
