class Blog
  module Views
    class Index < Mustache
      def posts
	Post.reverse_order(:created_at).limit(10).map do |p| {
	  :created_at_month => p[:created_at].strftime("%b"),
	  :created_at_date => p[:created_at].strftime("%d"),
	  :link => p.url,
	  :title => p[:title],
	  :linked_tags => p.linked_tags,
	  :summary_html => p.summary_html,
	  :'more?' => p.more?
	}
	end
      end
      def disqus?
	disqus_shortname ? true : false
      end
      def disqus_shortname
	Blog.settings[:disqus_shortname]
      end
    end
  end
end
