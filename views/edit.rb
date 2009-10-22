class Blog
  module Views
    class Edit < Mustache
      def entry_title
	@post[:title]
      end

      def entry_tags
	@post[:tags]
      end

      def entry_content
	@post[:body]
      end

      def timestamp
	t.strftime("%c") if t = @post[:created_at] 
      end
    end
  end
end
