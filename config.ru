require 'application'

Blog.set :environment, ENV['RACK_ENV'] || :development

Blog.run!
