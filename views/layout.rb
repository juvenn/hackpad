class Blog
  module Views
    class Layout < Mustache
      def blog_title
	Blog.settings[:title]
      end

      def blog_author
	Blog.settings[:author]
      end

    end
  end
end
