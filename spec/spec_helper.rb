require 'rack/test'
require 'rspec'
require 'bundler/setup'

ENV['RACK_ENV'] = 'test'

require 'active_record'
require File.expand_path '../../app.rb', __FILE__
Bundler.require


module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }