require "cassandra"

begin
  opts = {}
  opts[:username] = ENV["CASSANDRA_USERNAME"] if ENV["CASSANDRA_USERNAME"]
  opts[:password] = ENV["CASSANDRA_PASSWORD"] if ENV["CASSANDRA_PASSWORD"]
  opts[:hosts] = ENV["CASSANDRA_HOSTS"].split(",").map(&:strip) if ENV["CASSANDRA_HOSTS"]
  $cluster = Cassandra.cluster opts
  $db = $cluster.connect ENV["CASSANDRA_KEYSPACE"]
rescue => e
  puts "Failed to connect to cassandra cluster!"
  puts e.backtrace
end
