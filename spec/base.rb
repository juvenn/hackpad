$LOAD_PATH.unshift(File.dirname(__FILE__) + '/..')
require 'spec'
require 'sinatra/base'

# Change default env to test
# so `configure :test` works
Sinatra::Base.configure do |config|
  config.set :environment, :test
end

require 'application'
