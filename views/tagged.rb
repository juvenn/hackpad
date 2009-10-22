require 'views/index'

# Mustache (<= 0.4) has an issue on rendering within 
# partial's view, before that been addressed, we let
# Tagged inherit methods from Index.
class Tagged < Blog::Views::Index
end
