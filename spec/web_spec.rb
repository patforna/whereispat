require 'spec_helper'

describe 'The App' do
  
  def app
    Sinatra::Application
  end
  
  before(:each) do
    stub_request(:get, /.*user_timeline.json.*/).to_return(load('user_timeline.json'))
    stub_request(:get, /.*reverse_geocode.json.*/).to_return(load('reverse_geocode.json'))
  end  

  it "should show the last tweet" do
    get '/'    
    last_response.body.should include '@daniel_otte I also miss you guys. Hope things are ok.'    
  end
  
  it "should show the last known location" do 
    pending ("would have to update stubbing of reverse geocoding above...") do
      get '/'
      last_response.body.should include 'La Spezia, La Spezia'    
    end
  end
  
  private
  def load(file)
    File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'curl', file))
  end
    
  
end