require 'spec_helper'

describe Helpers do
  it "should auto link urls" do
    auto_link('Foo http://www.bar.com Baz').should == 'Foo <a href="http://www.bar.com">http://www.bar.com</a> Baz'
  end
end