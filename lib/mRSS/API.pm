package mRSS::API;

use strict;
use warnings;

use Dancer2 appname => 'mRSS::App';
use Dancer2::Plugin::Ajax;
use mRSS::ObjStorage;
use mRSS::Feed;
use mRSS::Article;
use mRSS::Cursor;

our $VERSION = '0.1';

$mRSS::ObjStorage::conf = $ENV{DB_CFG_FILE} // config->{db_cfg_file};

#TODO validate all input
set serializer => 'JSON';
prefix '/api';

get '/feeds' => sub {
	my $rs = mRSS::Feed->_rs->search();
	my @fields = qw/id name enabled url created last_retrieved n_retrieved update_interval/;
	my $iter = $rs->search();
	my @feeds;
	while(my $row = $iter->next()) {
		my $feed =  { map { $_ => $row->get_column($_) } @fields };
		$feed->{total} = $row->articles->count();
		$feed->{unread} = $row->articles->search( { read => 0 })->count();
		push @feeds, $feed;
	}
	#content_type 'application/json';
	return \@feeds;
};

get '/feed/:id/articles' => sub {
	my $rs = mRSS::Article->_rs;
	my @fields = qw/id title/;
	my $rows = 20;
	my $page = 1;
	if (defined(params->{page}) && params->{page} =~ /^\d+$/) {
		$page = params->{page}
	}
	my $iter = $rs->search({'feed' => params->{id}, read => 0 }, {
		order_by => { -desc => 'issued' },
		rows => $rows,
		page => $page
	});
	my $pager = $iter->pager();
	my @articles;
	while(my $row = $iter->next()) {
		my $article =  { map { $_ => $row->get_column($_) } @fields };
		push @articles, $article;
	}
	#content_type 'application/json';
	my $return_hash = {
		articles => \@articles,
		pager => {
			first => $pager->first_page(),
			last => $pager->last_page(),
			current => $pager->current_page,
		},
	};
	return $return_hash;
};

get qr{/article/(?<id>\d+)} => sub {
	my $rs = mRSS::Article->_rs;
	my @fields = qw/id title issued description read favorite/;
	my $captures = captures;
	my $article_row = $rs->find($captures->{id});
	my $article =  { map { $_ => $article_row->get_column($_) } @fields };
	#content_type 'application/json';
	return $article;
};

post qr{/article/(?<id>\d+)} => sub {
	my $rs = mRSS::Article->_rs;
	my $params = body_parameters;
	debug $params;
	debug query_parameters;
	debug route_parameters;
	my @fields = qw/id title issued description read favorite/;
	my $captures = captures;
	my $article = mRSS::Article->find( $captures->{id} );
	if(exists $params->{read}) {
		my $read = $params->{read};
		if ($read =~ /^(0|1)$/) {
			debug "Setting read: " . $read;
			$article->read($read);
		}
	}
	if(exists $params->{favorite}) {
		my $favorite = $params->{favorite};
		if ($favorite =~ /^(0|1)$/) {
			$article->favorite($favorite);
		}
	}
	#TODO should be able to just use the object.
	my $article_row = $article->_storage();
	my $return_article =  { map { $_ => $article_row->get_column($_) } @fields };
	return $return_article;
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
