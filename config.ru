require 'sinatra/base'

Sinatra::Base.configure do |config|
  config.set :environment, ENV['RACK_ENV'].to_sym || :development
end

require 'application'
Blog.run!
