require 'rubygems'
require 'bundler'

Bundler.setup

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'spec/autorun'
require 'spec/rails'

require 'state_event'

Spec::Runner.configure do |config|
  
end
