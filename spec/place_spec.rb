require 'spec_helper'

describe Place do                                              
  describe "parse" do
    it "should recognise latitude and longitude" do 
      should_parse "42.0123,8.9876", 42.0123, 8.9876
      should_parse "13.01,10.2", 13.01, 10.2      
    end
    
    it "should recognise negative latitude and longitude" do 
      should_parse "42.01,-8.9", 42.01, -8.9
      should_parse "-42.01,8.9", -42.01, 8.9
      should_parse "-42.01,-8.9", -42.01, -8.9            
    end
        
    it "should cope with surrounding text" do 
      should_parse "foo bar -42.0,7.0 baz #biz", -42.0, 7.0
      should_parse "42.0,-7.0 bar  ", 42.0, -7.0
      should_parse "  foo 42.0,7.0", 42.0, 7.0     
    end
    
    private
    def should_parse(message, latitude, longitude)
      place = Place.parse message
      place.latitude.should == latitude
      place.longitude.should == longitude      
    end
    
  end
end


# sign of live
#  tweet
#  place