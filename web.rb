require 'sinatra'
require 'twitter'

average_cycling_speed_mph = 15
start_date = Time.new(2012,4,3)

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
  @past_locations = Array.new()

  @last_tweet_with_a_location = nil
  tweets.each {|tweet|
    
    # if tweet has data and we've not yet got a tweet with a location then grab it as the lastest locatable tweet
    if !tweet.geo.nil? && @last_tweet_with_a_location.nil?
      @last_tweet_with_a_location = tweet
    end
   
    # if the tweet has geo data and is after the start date... let's track it! 
    if !tweet.geo.nil? && (tweet.created_at <=> start_date) == 1
      @past_locations.push({:lat => tweet.geo.latitude, :long => tweet.geo.longitude})
    end
  }

  @hours_since_last_tweet = ((Time.new() - @last_tweet.created_at) / 3600).round
  @how_far_might_he_have_gone = @hours_since_last_tweet * average_cycling_speed_mph

  @last_location = Twitter.reverse_geocode(:lat => @last_tweet_with_a_location.geo.latitude, :long => @last_tweet_with_a_location.geo.longitude, :max_results => 1).first

 

  erb :index
end
