require 'json'
require 'geokit'

class Place
  LAT_LONG_PATTERN = /(^|(.* ))(-?\d+\.\d+),(-?\d+\.\d+)( .*|$)/
  UNKNOWN = "Not sure the name of the place"
  
  attr_reader :latitude, :longitude, :visited_at
  
  def self.parse(tweet)
    if tweet.geo
      Place.new(tweet.geo.latitude, tweet.geo.longitude, tweet.created_at)
    else
      tweet.text =~ LAT_LONG_PATTERN
      Place.new($3, $4, tweet.created_at)
    end    
  end    
  
  def initialize(latitude=nil, longitude=nil, visited_at=nil)
    @latitude = latitude.to_f if latitude
    @longitude = longitude.to_f if longitude
    @visited_at = visited_at
  end
  
  def unknown?
    @latitude.nil? || @longitude.nil?
  end
    
  def name
    @name = compute_name if @name.nil?
  end
  
  def to_json(*a)
    {:latitude => @latitude, :longitude => @longitude, :visited_at => @visited_at}.to_json(*a)
  end
  
  def ==(other)
    @latitude == other.latitude && @longitude == other.longitude
  end
  
  private
  def compute_name
    begin
      geoLoc = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(GeoKit::LatLng.new(latitude, longitude))
      geoLoc.city || geoLoc.country ? [geoLoc.city, geoLoc.country].compact.join(', ') : UNKNOWN
    rescue
      UNKNOWN
    end
  end
  
end
