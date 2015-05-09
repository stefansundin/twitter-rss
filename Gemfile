source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rack"
gem "sinatra"
gem "bundler"
gem "unicorn"
gem "redis"
gem "redis-namespace"
gem "cassandra-driver"
gem "httparty"
gem "newrelic_rpm"
gem "rack-ssl-enforcer"
gem "clogger"
gem "heroku-env"

source "https://repo.fury.io/stefansundin/" do
  gem "twitter"
end

group :development do
  gem "rake"
  gem "sinatra-reloader"
  gem "powder"
  gem "dotenv"
  gem "binding_of_caller"
  gem "better_errors"
  gem "pry-remote"
  gem "github-release-party"
end
