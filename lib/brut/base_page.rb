require_relative "renderable"
require_relative "null_template_locator"

class Brut::BasePage < Brut::Renderable
  attr_reader :content, :errors
  attr_writer :page_locator, :layout_locator

  def initialize(content: {}, errors: [])
    super()
    @content        = content
    @errors         = errors
    @page_locator   = Brut::NullTemplateLocator.new
    @layout_locator = Brut::NullTemplateLocator.new
  end
  def errors? = !@errors.empty?

  def template_name = underscore(self.class.name).gsub(/^pages\//,"")
  def layout = "default"

  def render
    layout_erb_file = @layout_locator.locate(self.layout)
    layout_template = ERB.new(File.read(layout_erb_file))

    erb_file = @page_locator.locate(self.template_name)
    template = ERB.new(File.read(erb_file))

    template_binding = self.binding_scope do
      scope = self.binding_scope
      template.result(scope)
    end
    layout_template.result(template_binding)
  end
end

