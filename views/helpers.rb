class Blog
  module Views
    module Helpers
      def disqus?
	disqus_shortname ? true : false
      end
      def disqus_shortname
	Blog.settings[:disqus_shortname]
      end
    end
  end
end
