require "redis"

ENV["REDIS_URL"] ||= ENV["REDISCLOUD_URL"] || ENV["REDISTOGO_URL"]

begin
  $redis = Redis.new path: ENV["REDIS_SOCKET"], db: ENV["REDIS_DB"]
rescue => e
  puts "Failed to connect to redis!"
  puts e.backtrace
end
