DROP TABLE articles;
DROP TABLE feeds;

CREATE TABLE feeds (
	id serial primary key,
	name varchar(255) UNIQUE,
	url text,
	created timestamp with time zone,
	n_retrieved integer,
	last_retrieved timestamp with time zone,
	update_interval interval,
	enabled boolean DEFAULT true NOT NULL
);

CREATE TABLE articles (
	id serial primary key,
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

CREATE INDEX articles_feed_count on articles (feed);

