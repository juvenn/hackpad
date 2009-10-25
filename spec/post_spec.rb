require 'base'

describe Post do
	before do
		@post = Post.new
	        @post.save
	end

        def app
                Blog
        end

	it "has a url in format: /p/:id" do
		@post.url.should == "/p/#{@post.id}"
	end

	it "produces html from the markdown body" do
		@post.body = "* Bullet"
		@post.body_html.should == "<ul>\n<li>Bullet</li>\n</ul>"
	end

	it "syntax highlights code blocks" do
		@post.to_html("<code>\none\ntwo\n</code>").should == "\n<code><pre>\n<span class=\"ident\">one</span>\n<span class=\"ident\">two</span>\n</pre></code>\n"
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

	it "has automatically created timestamp" do
	        @post.title = 'movie'
		@post.body = 'good movie'
		@post.save
		@post[:created_at].should_not == nil
	end

end
