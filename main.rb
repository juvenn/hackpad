require 'rubygems'
require 'sinatra'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/sequel'
require 'sequel'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/mustache'
require 'mustache/sinatra'


configure do
	Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://blog.db')

	set :mustaches, 'views/'

	set :blog, {
	  :title => 'hackpad',
	  :author => 'Juvenn Woo',
	  :url_base => 'http://juvenn.heroku.com/',
	  :admin_password => 'ideal328',
	  :admin_cookie_key => 'juvenn',
	  :admin_cookie_value => 'juvenninside',
	  :disqus_shortname => 'hackinrandom'
	}
end

error do
	e = request.env['sinatra.error']
	puts e.to_s
	puts e.backtrace.join("\n")
	"Application error"
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'post'

helpers do
	def admin?
		request.cookies[options.blog.admin_cookie_key] == options.blog.admin_cookie_value
	end

	def auth
		stop [ 401, 'Not authorized' ] unless admin?
	end
end


### Public

get '/' do
	posts = Post.reverse_order(:created_at).limit(10)
	erb :index, :locals => { :posts => posts }, :layout => false
end

get '/p/:id' do
	post = Post[:id]
	stop [ 404, "Page not found" ] unless post
	@title = post.title
	erb :post, :locals => { :post => post }
end

get '/archive' do
	posts = Post.reverse_order(:created_at)
	@title = "Archive"
	erb :archive, :locals => { :posts => posts }
end

get '/tags/:tag' do
	tag = params[:tag]
	posts = Post.filter(:tags.like("%#{tag}%")).reverse_order(:created_at).limit(30)
	@title = "Posts tagged #{tag}"
	erb :tagged, :locals => { :posts => posts, :tag => tag }
end

get '/atom' do
	@posts = Post.reverse_order(:created_at).limit(20)
	content_type 'application/atom+xml', :charset => 'utf-8'
	builder :feed
end

### Admin

get '/auth' do
	erb :auth
end

post '/auth' do
	set_cookie(Blog.admin_cookie_key, Blog.admin_cookie_value) if params[:password] == Blog.admin_password
	redirect '/'
end

get '/new' do
	auth
	erb :edit, :locals => { :post => Post.new, :url => '/new' }
end

post '/new' do
	auth
	post = Post.new :title => params[:title], :tags => params[:tags], :body => params[:body], :created_at => Time.now
	post.save
	redirect post.url
end

get '/p/:id/edit' do
	auth
	post = Post[:id]
	stop [ 404, "Page not found" ] unless post
	erb :edit, :locals => { :post => post, :url => post.url }
end

post '/a/:id' do
	auth
	post = Post[:id]
	stop [ 404, "Page not found" ] unless post
	post.title = params[:title]
	post.tags = params[:tags]
	post.body = params[:body]
	post.save
	redirect post.url
end

