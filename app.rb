require "sinatra"
require "./config/application"
require "erb"


get "/" do
  @ratelimit = {limit: 0, remaining: 0, reset: Time.now}
  erb :index
end

get "/go" do
  params[:q] = "infected" if params[:q].nil? or params[:q].empty?
  user = $twitter.user(params[:q]) rescue nil
  return "There does not seem to be a user with the name #{params[:q]}." if user.nil?
  redirect "/#{user.id}#@#{user.username}"
end

get "/@:user" do
  user = $twitter.user(params[:user]) rescue nil
  redirect "/#{user.id}#@#{user.username}"
end

get %r{/(?<user_id>\d+)$} do |user_id|
  @user_id = user_id.to_i

  @username = $redis.get("username:#{user_id}")
  if not @username
    user = $twitter.user(user_id) rescue nil
    return "There does not seem to be a user with the id #{@user_id}." if user.nil?
    @username = user.username
    $redis.setex "username:#{@user_id}", 24*60*60, @username
  end

  data = $redis.get("tweets:#{@user_id}")
  if data
    @tweets = JSON.parse data
  else
    new_tweets = $twitter.user_timeline(@user, count: 200) rescue nil
    return "There does not seem to be a user with the id #{@user_id}." if new_tweets.nil?

    if new_tweets
      new_tweets.each do |tweet|
        $db.execute "INSERT INTO tweets (id, user_id, date, message) VALUES (?, ?, ?, ?)", arguments: [tweet.id, tweet.user.id, tweet.created_at, tweet.text]
      end
    end

    @tweets = $db.execute("SELECT date, id, message FROM tweets WHERE user_id=? ORDER BY date DESC LIMIT 50", arguments: [@user_id]).to_a
    $redis.setex "tweets:#{@user_id}", 10*60, @tweets.to_json
  end

  headers "Content-Type" => "application/atom+xml;charset=utf-8"
  erb :feed
end

get "/favicon.ico" do
  redirect "/img/icon32.png"
end

if ENV["GOOGLE_VERIFICATION_TOKEN"]
  /(google)?(?<google_token>[0-9a-f]+)(\.html)?/ =~ ENV["GOOGLE_VERIFICATION_TOKEN"]
  get "/google#{google_token}.html" do
    "google-site-verification: google#{google_token}.html"
  end
end

if ENV["LOADERIO_VERIFICATION_TOKEN"]
  /(loaderio-)?(?<loaderio_token>[0-9a-f]+)/ =~ ENV["LOADERIO_VERIFICATION_TOKEN"]
  get Regexp.new("^/loaderio-#{loaderio_token}") do
    headers "Content-Type" => "text/plain"
    "loaderio-#{loaderio_token}"
  end
end


error do
  "Sorry, a nasty error occurred: #{env["sinatra.error"].name}"
end
