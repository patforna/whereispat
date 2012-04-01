require 'sinatra'
require 'twitter'

Twitter.configure do |config|                        
  config.endpoint = 'http://' + ENV['APIGEE_TWITTER_API_ENDPOINT']     
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

get '/' do
  @tweet = Twitter.user_timeline("patforna").first  
  @location = Twitter.reverse_geocode(:lat => @tweet.geo.latitude, :long => @tweet.geo.longitude, :max_results => 1).first
  erb :index
end
