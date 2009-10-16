require File.dirname(__FILE__) + '/base'

describe Post do
	before do
		@post = Post.new
	end

	it "has a url in format: /p/:id" do
		@post.url.should =~ '/p/#{{@post.id}}'
	end

	it "has a full url including the Blog.url_base" do
		Blog.stub!(:url_base).and_return('http://blog.example.com/')
		@post.full_url.should == 'http://blog.example.com/p/#{{@post.id}}'
	end

	it "produces html from the markdown body" do
		@post.body = "* Bullet"
		@post.body_html.should == "<ul>\n<li>Bullet</li>\n</ul>"
	end

	it "syntax highlights code blocks" do
		@post.to_html("<code>\none\ntwo</code>").should == "<code><pre>\n<span class=\"ident\">one</span>\n<span class=\"ident\">two</span></pre></code>"
	end

	it "makes the tags into links to the tag search" do
		@post.tags = "one two"
		@post.linked_tags.should == '<a href="/tags/one">one</a> <a href="/tags/two">two</a>'
	end

	it "can save itself (primary key is set up)" do
		@post.title = 'hello'
		@post.body = 'world'
		@post.save
		Post.filter(:title => 'hello').first.body.should == 'world'
	end

end
