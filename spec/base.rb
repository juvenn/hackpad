$LOAD_PATH.unshift(File.dirname(__FILE__) + '/..')
require 'spec'
require 'sinatra/base'

Sinatra::Base.configure do |config|
  config.set :environment, :test
end

require 'application'
