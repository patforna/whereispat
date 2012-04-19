class Route
  
  attr_reader :places
  
  def self.from(tweets)
    places = tweets.map { |tweet| Place.parse(tweet) }
    Route.new(places.reverse.select { |place| !place.unknown? })
  end
  
  def initialize(places)
    @places = places
  end
  
  def last_place
    @places.last
  end
  
end