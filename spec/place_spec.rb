require 'spec_helper'

describe Place do
  
  describe "parse tweet" do
    it "should regognise latitude and longitude" do
      tweet = Twitter::Status.new('geo' => {'type' => 'Point', "coordinates" => [13.2, -7.6]})
      should_parse tweet, 13.2, -7.6
    end
    
    it "should regognise time when tweet was created" do
      time = Time.new(2012,4,10)
      tweet = Twitter::Status.new('created_at' => time.to_s)
      Place.parse(tweet).visited_at.should == time
    end
    
    it "should know what message was tweeted at this place" do
      tweet = tweet("foo")
      Place.parse(tweet).tweet == tweet
    end    
  end
                                                
  describe "parse tweet with no implicit geo data" do
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
    
    it "should indicate place is unknown if no geo data" do
      Place.parse(tweet("no geo data in here")).unknown?.should be_true
    end    
  end
  
  describe "compute name of place" do
    it "should use Google API to reverse geocode latitude and longitude" do
      latitude, longitude = 40, 10
      geoLoc = double('geoLoc')
      geoLoc.should_receive(:full_address).and_return("Foo, Bar")      
      Geokit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode).with(Geokit::LatLng.new(latitude, longitude)).and_return(geoLoc)
      Place.new(latitude, longitude).name.should == "Foo, Bar"
    end
    
    it "should limit to last two address components if there are more" do
      geoLoc = double('geoLoc')
      geoLoc.should_receive(:full_address).and_return("Foo, Bar, Baz")      
      Geokit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode).and_return(geoLoc)
      Place.new(0, 0).name.should == "Bar, Baz"
    end    
    
    it "should get rid of numbers in address components - at beginning" do
      geoLoc = double('geoLoc')
      geoLoc.should_receive(:full_address).and_return("Foo, Bar 11234, Baz")      
      Geokit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode).and_return(geoLoc)
      Place.new(0, 0).name.should == "Bar, Baz"
    end    

    it "should get rid of numbers in address components - at end" do
      geoLoc = double('geoLoc')
      geoLoc.should_receive(:full_address).and_return("11234 Bar, Baz")      
      Geokit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode).and_return(geoLoc)
      Place.new(0, 0).name.should == "Bar, Baz"
    end        
    
    it "should use cache response computed on reverse geocoding" do
      Geokit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode)
      place = Place.new
      place.name
      place.name
    end    
    
    it "should fall back to sensible message when things go haywire" do
      Geokit::Geocoders::GoogleGeocoder.should_receive(:reverse_geocode).and_raise(:boom)
      Place.new(0, 0).name.should == "Not sure the name of the place"
    end    
  end
  
  describe "when two places should be equal" do
    it "should be equal if same latitude and longitude" do
      Place.new(0, 0).should == Place.new(0, 0)
      Place.new(10, -10).should == Place.new(10, -10)
    end
    
    it "should not be equal if different latitude or longitude" do
      Place.new(2, 1).should_not == Place.new(1, 2)
      Place.new(1, 1).should_not == Place.new(1, -1)  
    end    
  end
  
  describe "json serialisation" do
    it "should serialise fields to JSON" do
      now_ish = Time.now
      tweet = tweet("foo")
      Place.new(1.1, 2.2,now_ish,tweet).to_json.should be_json_eql(%({"latitude":1.1, "longitude":2.2, "visited_at":"#{now_ish}", "tweet":"foo"}))
    end
    
    it "should HTML escape tweet message" do
      Place.parse(tweet('some "double" quotes')).to_json.should include('some &quot;double&quot; quotes')
    end
    
  end
  
  def should_parse(tweet, latitude, longitude)
    place = Place.parse tweet
    place.latitude.should == latitude
    place.longitude.should == longitude      
  end

end