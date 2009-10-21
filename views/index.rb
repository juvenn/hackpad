class Blog
  module Views
    class Index < Mustache
      include Helpers

      def posts
	@posts.map do |p| {
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
    end
  end
end
