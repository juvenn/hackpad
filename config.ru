require 'rubygems'

require 'application'
Blog.default_options.merge!(
  :views => File.join(File.dirname(__FILE__), 'views'),
  :run => false,
  :env => ENV['RACK_ENV']
)

Blog.run!
