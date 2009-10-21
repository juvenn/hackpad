class Blog
  module Views
    class Archive < Mustache
      def posts
	Post.reverse_order(:created_at).map do |p| {
	  :entry_title => p[:title],
	  :entry_link => p.url,
	  :timestamp => p[:created_at].strftime("%b %d %Y")
	}
	end
      end
    end
  end
end
