require_relative "renderable"
class Brut::BaseComponent < Brut::Renderable
  def template_name = underscore(self.class.name).gsub(/^components\//,"")
  def render
    erb_file = @component_locator.locate(self.template_name)
    template = ERB.new(File.read(erb_file))

    scope = self.binding_scope
    template.result(scope)
  end
end
