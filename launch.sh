export WEBAPI_DBIC_SCHEMA=mRSS::Schema
export WEBAPI_DBIC_HTTP_AUTH_TYPE=none # recommended
export DBI_DSN=dbi:SQLite:dbname=/home/slvrgale/code/mRSS-JSONAPI/rss.db
#export DBI_USER=... # for initial connection, if needed
#export DBI_PASS=... # for initial connection, if needed
#plackup -Ilib webapi-dbic-any.psgi
#plackup -Ilib --port 3000 bin/app-full.pl 
starman -E development -Ilib --port 3000 --access-log logs/access.log bin/app-full.pl 
#starman -E development -Ilib --port 3000 --access-log logs/access.log --error-log logs/errors.log bin/app-full.pl 
