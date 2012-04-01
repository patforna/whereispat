require 'sinatra'
require 'twitter'

get '/' do
  #@tweet = Twitter.user_timeline("patforna").first.text
  @tweet = "We're in the corner."
  #Twitter.reverse_geocode(:lat => "37.7821120598956", :long => "-122.400612831116")
  
  erb :index
end
