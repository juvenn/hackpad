$LOAD_PATH.unshift(File.dirname(__FILE__) + '/..')
require 'application'
require 'spec'

Blog.set :environment, :test

