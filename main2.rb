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
    def admin?
      request.cookies[Blog.settings[:admin_cookie_key]] == Blog.settings[:admin_cookie_value]
    end

    def auth
      halt [ 401, 'Not authorized' ] unless admin?
    end
  end

  ######## Public

  get '/' do
    mustache :index
  end

  get %r{/p/([\d]+)} do |id|
    # Instance variables will be copied to Mustache views
    # See Mustache::Sinatra::Helpers#render_mustache
    @post = Post[id]
    halt [404, "Article not found"] unless @post
    mustache :post, :locals => {:admin? => admin?} 
  end

end

# Instead of requiring in every views,
# requiring here for DRY's principle
require 'views/helpers'

Blog.run!
