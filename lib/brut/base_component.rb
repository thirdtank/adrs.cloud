require_relative "renderable"
class Brut::BaseComponent < Brut::Renderable
  def template_name = underscore(self.class.name).gsub(/^components\//,"")
end
