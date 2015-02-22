require "sinatra"
require "sinatra/reloader" if development?
require "./config/application"
require "erb"


get "/" do
  @ratelimit = {limit: 0, remaining: 0, reset: Time.now}
  erb :index
end

get "/go" do
  params[:user] = "infected" if params[:user].nil? or params[:user].empty?
  redirect "/@#{params[:user]}"
end

get "/@:user" do
  @user = params[:user]
  user_id = $redis.get("user_id:#{@user}")
  return "Don't have the user_id for #{@user}, sorry." if user_id.nil?
  user_id = user_id.to_i

  @tweets = $db.execute("SELECT date, id, message FROM tweets WHERE user_id=? ORDER BY date DESC LIMIT 50", user_id).to_a

  headers "Content-Type" => "application/atom+xml;charset=utf-8"
  erb :feed
end

get "/fetch/@:user" do
  @user = params[:user]
  @tweets = $twitter.user_timeline(@user, count: 200) rescue nil

  return "Unfortunately there does not seem to be a user with the name #{@user}." if @tweets.nil?

  $redis.set("user_id:#{@user}", @tweets[0].user.id)

  @tweets.each do |tweet|
    $db.execute "INSERT INTO tweets (id, user_id, date, message) VALUES (?, ?, ?, ?)", tweet.id, tweet.user.id, tweet.created_at, tweet.text
  end

  headers "Content-Type" => "text/plain"
  "Tweets stored"
end

get "/favicon.ico" do
  redirect "https://twitter.com/favicon.ico"
end

get "/robots.txt" do
  # only allow root to be indexed
  headers "Content-Type" => "text/plain"
  <<eos
User-agent: *
Allow: /$
Disallow: /
eos
end

get %r{^/loaderio-c8b2f36404a8cc878bdd10a682ead986} do
  headers "Content-Type" => "text/plain"
  "loaderio-c8b2f36404a8cc878bdd10a682ead986"
end

get "/googlecd2a49223a3e752f.html" do
  "google-site-verification: googlecd2a49223a3e752f.html"
end


error do
  "Sorry, a nasty error occurred: #{env["sinatra.error"].name}"
end
