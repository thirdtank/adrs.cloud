puts "brut/component.rb required"
module Brut::Components
  autoload(:Input,"brut/components/input")
  autoload(:Inputs,"brut/components/input")
end
class Brut::Component < Brut::Renderable
  def template_name = underscore(self.class.name).gsub(/^components\//,"")
  def render
    erb_file = @component_locator.locate(self.template_name)
    template = ERB.new(File.read(erb_file))

    scope = self.binding_scope
    template.result(scope)
  end
end
