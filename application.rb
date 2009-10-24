require 'rubygems'
require 'sinatra/base'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/sequel'
require 'sequel'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/mustache'
require 'mustache/sinatra'


class Blog < Sinatra::Base
  register Mustache::Sinatra

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

  set :app_file, caller_files.first || $0
  set :run, Proc.new { $0 == app_file }
  enable :static, :dump_errors
  set :mustaches, 'views/'
  
  configure :production do
    Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://blog.db')
    enable :logging
  end

  configure :development do
    Sequel.connect('sqlite://blog.db')
    enable :logging, :show_exceptions
  end

  configure :test do
    Sequel.connect('sqlite://blog_test.db')
    enable :raise_errors
  end

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

  require 'lib/post'

  ######## Public

  get '/' do
    @posts = Post.reverse_order(:created_at).limit(10)
    mustache :index
  end

  get %r{/p/([\d]+)$} do |id|
    @post = Post[id]
    halt [404, "Post not found"] unless @post
    mustache :post, :locals => {:admin? => admin?} 
  end

  get '/archive' do
    mustache :archive
  end

  get '/tags/:tag' do
    tag = params[:tag]
    @posts = Post.filter(:tags.like("%#{tag}%")).reverse_order(:created_at).limit(30)
    mustache :tagged, :locals => {:tag => tag}
  end

  get '/atom' do
    @posts = Post.reverse_order(:created_at).limit(20)
    content_type 'application/atom+xml', :charset => 'utf-8'
    builder :feed
  end

  #### Admin

  get '/auth' do
    mustache :auth
  end

  post '/auth' do
    response.set_cookie(Blog.settings[:admin_cookie_key],Blog.settings[:admin_cookie_value]) if params[:password] == Blog.settings[:admin_password]
    redirect '/'
  end

  get '/new' do
    auth
    @post = Post.new
    mustache :edit, :locals => {:action => '/new'}
  end

  post '/new' do
    auth
    post = Post.new(:title => params[:title],
		    :tags => params[:tags],
		    :body => params[:body],
		    :created_at => Time.now)
    post.save
    redirect post.url
  end

  get %r{/p/([\d]+)/edit} do |id|
    auth
    @post = Post[id]
    halt [404, "Page not found"] unless @post
    mustache :edit, :locals => {:action => @post.url}
  end

  post %r{/p/([\d]+)$} do |id|
    auth
    @post = Post[id]
    halt [404, "Page not found"] unless @post
    @post.title = params[:title]
    @post.tags = params[:tags]
    @post.body = params[:body]
    @post.save
    redirect @post.url
  end

end

require 'views/helpers'

if Blog.run?
  Blog.run!
end
