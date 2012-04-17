require 'spec_helper'
require 'twitter'

describe Place do
  
  describe "parse tweet with geo data" do
    it "should regognise latitude and longitude" do
      tweet = Twitter::Status.new('geo' => {'type' => 'Point', "coordinates" => [13.2, -7.6]})
      should_parse tweet, 13.2, -7.6
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
  
  describe "compute name of place" do
    it "should use Twitter API to reverse geocode latitude and longitude" do
      latitude, longitude, name = 40, 10, 'foo'
      twitter_results = [Twitter::Place.new('full_name' => name)]
      Twitter.should_receive(:reverse_geocode).with(hash_including(:lat => latitude, :long => longitude)).and_return(twitter_results)
      Place.new(latitude, longitude).name.should == name
    end
    
    it "should fall back to sensible message when things go haywire" do
      Twitter.should_receive(:reverse_geocode).and_raise(:boom)
      Place.new(0, 0).name.should == "Not sure the name of the place"
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