begin
  redis = Redis.new path: ENV["REDIS_SOCKET"], db: ENV["REDIS_DB"]
  $redis = Redis::Namespace.new :twitter_rss, redis: $redis
rescue => e
  puts "Failed to connect to redis!"
  puts e.backtrace
end
