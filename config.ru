

# require 'bundler'

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'active_record'
require './app'

Bundler.require
run Sinatra::Application