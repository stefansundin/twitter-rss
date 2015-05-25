ENV["RACK_ENV"] ||= "development"
if ENV["RACK_ENV"] == "development"
  # better_errors and binding_of_caller works better with only one process
  worker_processes 1
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
end

timeout 60
preload_app true

app_path = File.expand_path("../..", __FILE__)
working_directory app_path
# pid app_path + "/tmp/unicorn.pid"
# stdout_path app_path + "/log/unicorn-stdout.log"
# stderr_path app_path + "/log/unicorn-stderr.log"
# listen app_path + "/tmp/unicorn.sock", backlog: 64
# listen 3000, backlog: 64


before_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn master intercepting TERM and sending myself QUIT instead"
    Process.kill "QUIT", Process.pid
  end
  $redis.client.disconnect
  $cluster.close rescue nil
end

after_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT"
  end

  begin
    $redis.client.reconnect
  rescue => e
    puts "Failed to reconnect to redis!"
    puts e.backtrace
  end

  # reconnect Cassandra
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
end
