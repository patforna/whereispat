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

  private
  def initialize(latitude, longitude)
    @latitude = latitude.to_f
    @longitude = longitude.to_f
  end
  
  TIMBUKTU = Place.new(16.7770957947, -3.00905203819)
end
