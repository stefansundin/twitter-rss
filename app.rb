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
  user = $twitter.user(params[:user]) rescue nil
  return "Unfortunately there does not seem to be a user with the name #{params[:user]}." if user.nil?
  redirect "/#{user.id}"
end

get "/@:user" do
  @user = params[:user]

  user_id = $redis.get("user_id:#{@user}")
  if user_id
    user_id = user_id.to_i
  else
    new_tweets = $twitter.user_timeline(@user, count: 200) rescue nil
    return "Unfortunately there does not seem to be a user with the name #{@user}." if new_tweets.nil?

    user_id = new_tweets[0].user.id
    $redis.set "user_id:#{@user}", user_id
    $redis.expire "user_id:#{@user}", 10*60

    if new_tweets
      new_tweets.each do |tweet|
        $db.execute "INSERT INTO tweets (id, user_id, date, message) VALUES (?, ?, ?, ?)", arguments: [tweet.id, tweet.user.id, tweet.created_at, tweet.text]
      end
    end
  end

  @tweets = $db.execute("SELECT date, id, message FROM tweets WHERE user_id=? ORDER BY date DESC LIMIT 50", arguments: [user_id]).to_a

  headers "Content-Type" => "application/atom+xml;charset=utf-8"
  erb :feed
end

get %r{/(?<user_id>\d+)} do |user_id|
  return user_id
end

get "/fetch/@:user" do
  @user = params[:user]
  new_tweets = $twitter.user_timeline(@user, count: 200) rescue nil

  return "Unfortunately there does not seem to be a user with the name #{@user}." if new_tweets.nil?

  user_id = new_tweets[0].user.id
  $redis.set "user_id:#{@user}", user_id
  $redis.expire "user_id:#{@user}", 10*60

  new_tweets.each do |tweet|
    $db.execute "INSERT INTO tweets (id, user_id, date, message) VALUES (?, ?, ?, ?)", arguments: [tweet.id, tweet.user.id, tweet.created_at, tweet.text]
  end

  headers "Content-Type" => "text/plain"
  "Tweets stored"
end

get "/favicon.ico" do
  redirect "https://stefansundin.github.io/twitter-rss/img/icon32.png"
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

get %r{^/loaderio-90e6b62352b9a16f867df699701fe5f0} do
  headers "Content-Type" => "text/plain"
  "loaderio-90e6b62352b9a16f867df699701fe5f0"
end

get "/googlecd2a49223a3e752f.html" do
  "google-site-verification: googlecd2a49223a3e752f.html"
end


error do
  "Sorry, a nasty error occurred: #{env["sinatra.error"].name}"
end
