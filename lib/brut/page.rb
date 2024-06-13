require "erb"

# A page is a component that has a layout and thus is intended to be
# an entire web page, not just a fragment.
class Brut::Page < Brut::Component
  attr_reader :content
  attr_writer :page_locator, :layout_locator

  def initialize(content: {})
    super()
    @content        = content
    @page_locator   = NullTemplateLocator.new
    @layout_locator = NullTemplateLocator.new
  end

  def layout = "default"

  # Overrides component's render to add the concept of a layout.
  # A layout is an HTML/ERB file that will contain this page's contents.
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

private

  def template_name = underscore(self.class.name).gsub(/^pages\//,"")
end

