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

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.include RSpecMixin
end