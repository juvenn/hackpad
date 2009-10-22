class Blog
  module Views
    class Post < Mustache
      include Helpers

      def entry_title
	@post[:title]
      end

      def entry_link
	@post.url
      end

      def entry_content
	@post.body_html
      end

      def timestamp
	@post[:created_at].strftime('%c')
      end

      def linked_tags
	@post.linked_tags
      end
    end
  end
end
