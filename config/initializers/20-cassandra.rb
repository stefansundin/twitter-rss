require "cassandra"

ENV["CASSANDRA_HOSTS"] ||= "localhost"

begin
  $cluster = Cassandra.cluster username: ENV["CASSANDRA_USERNAME"], password: ENV["CASSANDRA_PASSWORD"], hosts: ENV["CASSANDRA_HOSTS"].split(",").map(&:strip)
  $db = $cluster.connect(ENV["CASSANDRA_KEYSPACE"])
rescue => e
  puts "Failed to connect to cassandra cluster!"
  puts e.backtrace
end
