class Place
  
  LAT_LONG_PATTERN = /(^|(.* ))(-?\d+\.\d+),(-?\d+\.\d+)( .*|$)/
  
  attr_reader :latitude, :longitude    

  def initialize(latitude, longitude)
    @latitude = latitude.to_f
    @longitude = longitude.to_f
  end
  
  
  def self.parse(message)
    LAT_LONG_PATTERN.match(message)
    Place.new($3, $4)
  end
  
end
