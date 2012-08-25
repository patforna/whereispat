require 'sinatra'
require 'twitter'
require 'geokit'
require 'dalli'
require 'rack-cache'
require './lib/tweet'
require './lib/place'
require './lib/route'
require './lib/helpers'

Geokit::default_units = :kms
Geokit::default_formula = :sphere

average_cycling_speed_mph = 5

configure do
  $cache = Dalli::Client.new
  use Rack::Cache, :verbose => true, :metastore => $cache, :entitystore => $cache, :allow_reload => false
end

configure :production do
  Twitter.configure do |config|                        
    config.endpoint = 'http://' + ENV['APIGEE_TWITTER_API_ENDPOINT']     
    config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
  end
  set :static_cache_control, [:public, :max_age => 60]  
end

before do
  cache_control :public, :max_age => 60
end

get '/' do
  erb :frozen
end

# get '/' do
#   tweets = Tweet.load
#   @last_tweet = tweets.first
#   @route = Route.from(tweets)
#   @last_place = @route.last_place
# 
#   @hours_since_last_place = ((Time.new() - @last_place.visited_at) / 3600).round
#   @how_far_might_he_have_gone = @hours_since_last_place * average_cycling_speed_mph
# 
#   erb :index
# end

helpers do 
  include Helpers
end