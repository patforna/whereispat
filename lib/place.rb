class Place
  LAT_LONG_PATTERN = /(^|(.* ))(-?\d+\.\d+),(-?\d+\.\d+)( .*|$)/
  
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
  
  def ==(other)
    @latitude == other.latitude && @longitude == other.longitude
  end
  
  private
  def compute_name
    begin
      Twitter.reverse_geocode(:lat => @latitude, :long => @longitude, :max_results => 1, :granularity => "city").first.full_name
    rescue
      "Not sure the name of the place"
    end
  end
  
end
