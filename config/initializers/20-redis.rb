begin
  $redis = Redis::Namespace.new :twitter_rss
rescue => e
  puts "Failed to connect to redis!"
  puts e.backtrace
end
