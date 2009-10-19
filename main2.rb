require 'rubygems'
require 'sinatra/base'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/sequel'
require 'sequel'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/mustache'
require 'mustache/sinatra'


class Blog < Sinatra::Application
  register Mustache::Sinatra

  configure do
    Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://blog.db')
  end

  $LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
  require 'post'

  class << self; attr_reader :settings end
  @settings = {
    :title => 'hackpad',
    :author => 'Juvenn Woo',
    :url_base => 'http://juvenn.heroku.com/',
    :admin_password => 'ideal328',
    :admin_cookie_key => 'juvenn',
    :admin_cookie_value => 'juvenninside',
    :disqus_shortname => 'hackinrandom'
  }

  set :mustaches, 'views/'
  set :public, 'public/'
  
  error do
  end

  helpers do
  end

  ######## Public

  get '/' do
    mustache :index
  end

  get %r{/p/([\d]+)} do |:id|
    post = Post[:id]
    halt [404, "Article not found"] unless post
    mustache :post
  end

end

Blog.run!
