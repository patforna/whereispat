require 'sinatra'
require 'twitter'

average_cycling_speed_mph = 15

Twitter.configure do |config|                        
  config.endpoint = 'http://' + ENV['APIGEE_TWITTER_API_ENDPOINT']     
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

get '/' do

  tweets = Twitter.user_timeline("patforna")
  @last_tweet = tweets.first

  @last_tweet_with_a_location = nil
  tweets.each {|tweet|
    if !tweet.geo.nil?
      @last_tweet_with_a_location = tweet
      break
    end
  }

  puts @last_tweet.created_at.class.to_s

  @hours_since_last_tweet = ((Time.new() - @last_tweet.created_at) / 3600).round
  @how_far_might_he_have_gone = @hours_since_last_tweet * average_cycling_speed_mph

  @location = Twitter.reverse_geocode(:lat => @last_tweet_with_a_location.geo.latitude, :long => @last_tweet_with_a_location.geo.longitude, :max_results => 1).first

  erb :index
end
