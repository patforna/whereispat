class Place
  LAT_LONG_PATTERN = /(^|(.* ))(-?\d+\.\d+),(-?\d+\.\d+)( .*|$)/
  
  attr_reader :latitude, :longitude
  
  def self.parse(tweet)
    if tweet.geo
      Place.new(tweet.geo.latitude, tweet.geo.longitude)
    elsif tweet.text =~ LAT_LONG_PATTERN
      Place.new($3, $4)
    else
      TIMBUKTU
    end    
  end    
  
  def initialize(latitude, longitude)
    @latitude = latitude.to_f
    @longitude = longitude.to_f
  end
  
  def name
    begin
      Twitter.reverse_geocode(:lat => @latitude, :long => @longitude, :max_results => 1, :granularity => "city").first.full_name
    rescue
      "Not sure the name of the place"
    end
  end
  
  TIMBUKTU = Place.new(16.7770957947, -3.00905203819)
end
