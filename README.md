# Twitter to RSS Feed [![Code Climate](https://codeclimate.com/github/stefansundin/twitter-rss/badges/gpa.svg)](https://codeclimate.com/github/stefansundin/twitter-rss)

You can use this app freely at [twittrss.herokuapp.com](https://twittrss.herokuapp.com/), or deploy it yourself if you want to.

Deploy your own:

1. Create an app on [dev.twitter.com](https://dev.twitter.com/apps) (you need a Twitter account).
2. In the app, create an access token.
3. Click the button below to deploy the app on Heroku.
4. Copy your keys to the ENV variables.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/stefansundin/twitter-rss)

You have to [verify](https://heroku.com/verify) your Heroku account to add the free redis addon. You don't need a credit card if you create an account directly on [redislabs.com](https://redislabs.com).

Setup your Cassandra keyspace:

```
$ cqlsh
CREATE KEYSPACE twitter WITH REPLICATION = {'class':'SimpleStrategy','replication_factor':1};
USE twitter;
CREATE TABLE tweets (id bigint, user_id bigint, date timestamp, message text, error int, PRIMARY KEY (user_id, date, id)) WITH CLUSTERING ORDER BY (date DESC);
CREATE TABLE urls (url text primary key, resolved text, first_seen timestamp);
```

Notes:
- Links created in 2011 and earlier don't always have their urls as entities (they are not even autolinked when viewing them on twitter.com).
- Old tweets don't escape ampersands either.
- 180 requests can be done per 15 minutes.
- Based on my old PHP script: https://gist.github.com/stefansundin/5951213

Docs:
- https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
- https://dev.twitter.com/docs/rate-limiting/1.1
- https://dev.twitter.com/docs/tweet-entities
