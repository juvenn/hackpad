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

  enable :static
  set :mustaches, 'views/'
  set :views, 'views/'
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
    # Instance variables will be copied to Mustache views
    # See Mustache::Sinatra::Helpers#render_mustache
    @posts = Post.reverse_order(:created_at).limit(10)
    mustache :index
  end

  get %r{/p/([\d]+)} do |id|
    @post = Post[id]
    halt [404, "Post not found"] unless @post
    mustache :post, :locals => {:admin? => admin?} 
  end

  get '/archive' do
    mustache :archive
  end

  # TODO: patial rendering
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

end

# Instead of requiring in every views,
# requiring here for DRY's principle
require 'views/helpers'

Blog.run!
