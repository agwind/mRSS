## Getting started

### Setup your environment

I like to create a separate username and Perl environment for my application.  This isn't strictly necessary.  In the end it took around 250M to build and another 75M after the supporting libraries where installed.

Create a user

    # adduser rss

Install local::lib to make it easy to install perl modules in your own home directory, along with the standard build tools

    # apt-get install liblocal-lib-perl build-essential

Let's add environment variables to point to your local perl modules.  Add this to a $HOME/.perlenv

```bash
eval `perl -Mlocal::lib`
export PERL_MB_OPT="--install_base $HOME/perl5"
export PATH="$HOME/perl5/bin:$PATH"
```

Then source it from your $HOME/.bashrc

```bash
source $HOME/.perlenv
```

Install App::cpanminus

    # apt-get install cpanminus

### Install dependencies

Let's install some library dependencies as root first:

    # apt-get install libxml2-dev zlib1g-dev libexpat1-dev

If you're using PostgreSQL:

    # apt-get install libpq-dev

Do these steps as your user (rss).  Eventually I'll update the correct build files and all you'll need to do is cpanm <this repository url>

Let's upgrade cpanm (1.701 is current).

    $ cpanm --self-upgradde
    $ hash -r
    $ cpanm --version

Next install our dependencies

* DateTime
* HTTP::Tiny
* XML::Feed
* Text::Xslate
* Moose
* MooseX::StrictConstructor
* Dancer
* Dancer::Template::Xslate
* Config::Any
* DBIx::Class
* XML::Smart
* DBIx::Class::TimeStamp
* Config::General

Most of these are pretty straight forward, but I install them one at a time, to make sure I don't have any lib dependencies as I go (where I caught libxml2-dev, etc in the previous step)

    $ cpanm DateTime
    $ cpanm HTTP::Tiny
    ...

I've been using PostgreSQL and SQLite to develop this.  Install your database driver

    $ cpanm DBD::Pg 
    $ cpanm DBD::SQLite

I'm using starman as my http server.  If you go this route, install it too.

    $ cpanm Starman

I'm using a modified InflateColumn::DateTime::Duration so I don't have to monkey with my schema files:

    $ git clone https://github.com/agwind/DBIx-Class-InflateColumn-DateTime-Duration
    $ cd DBIx-Class-InflateColumn-DateTime-Duration/
    $ cpanm .


### Setup mRSS

Clone this repo

    $ git clone https://github.com/agwind/mRSS

Create your database.  I'm using SQLite for this example.

    $ cd mRSS
    $ sqlite3 rss.db < sql/tables.sqlite.sql

Modify your DB config

    $ cp dbic.sqlite.conf.example dbic.conf

Change
    
    lib </path/to/your/lib/mRSS>
    dsn     dbi:SQLite:dbname=<path/to/your/rss/db>

to:

    lib /home/rss/mRSS/lib/mRSS
    dsn     dbi:SQLite:dbname=/home/rss/mRSS/rss.db

Copy the main configuration file

   $ cp config.yml.example config.yml

Modify the users section to add a username and a unique password (a.k.a. not the one below)

    users:
      jimbob: 'rSs4u['

I don't have a daemon yet to automatically pull feeds, so cron it if you want to do it automatically

    22 */4 * * * /home/rss/mrss.sh

Where mrss.sh is simply:
```bash
#!/bin/bash
source $HOME/.perlenv
cd /home/rss/mRSS
perl bin/mrss.pl
```

### Import your RSS subscriptions

If you have your OPML file from a previous reader, you can simply import your subscriptions by running the import script.

    perl bin/import.pl google_reader.xml

If you don't have a ompl file, just copy the test one and add the name to the text="" attribute and the feed url to the xmlUrl attribute.

    $ cp t/import.xml myfeeds.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
 <head>
  <title>Test Subscriptions</title>
 </head>
 <body>
         <outline title="AgWind" text="AgWind" type="rss" xmlUrl="http://agwind.net/atom.xml" htmlUrl="http://localhost/"/>
         <outline title="AnandTech" text="AnandTech" type="rss" xmlUrl="http://www.anandtech.com/rss/" htmlUrl="http://www.anandtech.com"/>
 </body>
</opml>
```

    $ perl bin/import.pl myfeeds.xml

### Run!

I'm running Starman as my HTTP server on an alternative port since I have other things running on the default ports.  Firing up a server to run bin/app.pl should be all it takes to get going.

Since I'm running an alternative port, I'm going to poke a hole in the firewall

    # ufw allow 8080/tcp

Then I'll start up the app

    $ starman --listen 0:8080 bin/app.pl

I suggest starting it up with SSL if you are more than simply playing with the app

    $ starman --listen 0:8080:ssl --ssl-cert </path/to/your/ssl.crt> --ssl-key </path/to/your/ssl.key bin/app.pl

Point your browser to your new url, and happy RSS Reading!


## Copyright & License

Copyright (C) 2013, Benjamin Noggle,

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
