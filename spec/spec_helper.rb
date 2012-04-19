# unit tests
require 'place'

# functional tests
ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), '..', 'web.rb')
require 'rack/test'
require 'webmock/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include WebMock::API
end