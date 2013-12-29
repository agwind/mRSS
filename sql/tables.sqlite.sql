DROP TABLE IF EXISTS articles;
DROP TABLE IF EXISTS feeds;

CREATE TABLE feeds (
	id integer primary key autoincrement,
	name varchar(255) UNIQUE,
	url text,
	created timestamp with time zone,
	n_retrieved integer,
	last_retrieved timestamp with time zone,
	update_interval interval,
	enabled boolean DEFAULT true NOT NULL
);

CREATE TABLE articles (
	id integer primary key autoincrement,
	feed integer references feeds(id),
	title varchar(255),
	link text,
	description text,
	orig_description text,
	imported timestamp with time zone,
	read boolean DEFAULT false NOT NULL,
	favorite boolean DEFAULT false NOT NULL,
	read_date timestamp with time zone,
	issued timestamp with time zone,
	modified timestamp with time zone,
	UNIQUE (feed, title, link)
);
