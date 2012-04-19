require 'spec_helper'

describe Route do
  
  it "should create a route (consisting of places) from tweets - in reverse order" do
    route = Route.from [tweet("10.0,11.0"), tweet("20.0,21.0")]
    route.places[0].should == Place.new(20.0, 21.0)    
    route.places[1].should == Place.new(10.0, 11.0)
  end
  
  it "should not include unknown places" do
    route = Route.from [tweet("no geo data")]
    route.places.should have(0).items
  end
  
  it "should know the last place" do
    route = Route.from [tweet("10.0,11.0"), tweet("20.0,21.0")]
    route.last_place.should == Place.new(10.0, 11.0)
  end

end