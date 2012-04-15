require 'spec_helper'
require 'twitter'

describe Place do
  
  describe "parse tweet with geo data" do
    it "should regognise latitude and longitude" do
      tweet = Twitter::Status.new('geo' => {'type' => 'Point', "coordinates" => [13.2, 7.6]})
      should_parse tweet, 13.2, 7.6
    end
  end
                                                
  describe "parse tweet without geo data" do
    it "should recognise latitude and longitude" do 
      should_parse tweet("42.0123,8.9876"), 42.0123, 8.9876
      should_parse tweet("13.01,10.2"), 13.01, 10.2      
    end
    
    it "should recognise negative latitude and longitude" do 
      should_parse tweet("42.01,-8.9"), 42.01, -8.9
      should_parse tweet("-42.01,8.9"), -42.01, 8.9
      should_parse tweet("-42.01,-8.9"), -42.01, -8.9            
    end
        
    it "should cope with surrounding text" do 
      should_parse tweet("foo bar -42.0,7.0 baz #biz"), -42.0, 7.0
      should_parse tweet("42.0,-7.0 bar  "), 42.0, -7.0
      should_parse tweet("  foo 42.0,7.0"), 42.0, 7.0     
    end
    
    it "should fall back to Timbuktu if message can't be parsed" do
      TIMBUKTU_LATITUDE = 16.7770957947
      TIMBUKTU_LONGITUDE = -3.00905203819
      should_parse tweet("no geo data in here"), TIMBUKTU_LATITUDE, TIMBUKTU_LONGITUDE      
    end  
  end

  private
  def tweet(message) 
    Twitter::Status.new("text" => message)
  end
  
  def should_parse(tweet, latitude, longitude)
    place = Place.parse tweet
    place.latitude.should == latitude
    place.longitude.should == longitude      
  end

end


# sign of live
#  tweet
#  place