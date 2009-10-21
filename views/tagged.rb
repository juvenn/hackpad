class Blog
  module Views
    class Tagged < Mustache
      self.template_path = File.dirname(__FILE__)
      self.template_extension = 'mustache'
    end
  end
end
