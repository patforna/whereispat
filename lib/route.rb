require 'json'

class Route
  
  attr_reader :places
  
  def self.from(tweets)
    places = tweets.reverse.map { |tweet| Place.parse(tweet) }
    Route.new(places.select { |place| !place.unknown? })
  end
  
  def initialize(places)
    @places = places
  end
  
  def last_place
    @places.last
  end
  
  def to_json(*a)
    {:places => @places}.to_json(*a)
  end
  
end