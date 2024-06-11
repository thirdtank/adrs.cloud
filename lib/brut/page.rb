require "erb"
class Brut::Page < Brut::Renderable
  attr_reader :content
  attr_writer :page_locator, :layout_locator

  def initialize(content: {})
    super()
    @content        = content
    @page_locator   = NullTemplateLocator.new
    @layout_locator = NullTemplateLocator.new
  end

  def template_name = underscore(self.class.name).gsub(/^pages\//,"")
  def layout = "default"

  def render
    layout_erb_file = @layout_locator.locate(self.layout)
    layout_template = ERB.new(File.read(layout_erb_file))
    layout_template.location = [ layout_erb_file.to_s, 1 ]

    erb_file = @page_locator.locate(self.template_name)
    template = ERB.new(File.read(erb_file))
    template.location = [ erb_file.to_s, 1 ]

    template_binding = self.binding_scope do
      scope = self.binding_scope
      template.result(scope)
    end
    layout_template.result(template_binding)
  end
end

