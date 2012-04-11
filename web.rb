require 'sinatra'
require 'twitter'

average_cycling_speed_mph = 5
start_date = Time.new(2012,4,3)
regex_pattern = /.* (\d{1,2}\.\d{6}),(\d{1,2}\.\d{6}) .*/

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
    lat = nil
    long = nil
    
    # if tweet has data and we've not yet got a tweet with a location then grab it as the lastest locatable tweet
    if !tweet.geo.nil?
      lat = tweet.geo.latitude
      long = tweet.geo.longitude
    elsif tweet.text =~ regex_pattern 
      # his tweet contains lat and long...
      @last_tweet_with_a_text_location = tweet
      m = regex_pattern.match(@last_tweet_with_a_text_location.text)
      lat = m[1].to_f
      long = m[2].to_f
    end
   
    # if the tweet has geo data and is after the start date... let's track it! 
    if  !lat.nil? && !long.nil? && (tweet.created_at <=> start_date) == 1
      @past_locations.push({:lat => lat, :long => long, :time => tweet.created_at})
    end
  }

  @hours_since_last_tweet = ((Time.new() - @last_tweet.created_at) / 3600).round
  @how_far_might_he_have_gone = @hours_since_last_tweet * average_cycling_speed_mph

  @lookup_lat = @past_locations[0][:lat]
  @lookup_long = @past_locations[0][:long]
  @time_at_location = @past_locations[0][:time]

  begin
    @last_location = Twitter.reverse_geocode(:lat => @past_locations[0][:lat], :long => @past_locations[0][:long], :max_results => 1, :granularity => "city").first.full_name
  rescue
    @last_location = "Not sure the name of the place"
  end

 

  erb :index
end
