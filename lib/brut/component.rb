module Brut::Components
  autoload(:Input,"brut/components/input")
  autoload(:Inputs,"brut/components/input")
end
# A Component is the top level class for managing the rendering of 
# content.  A component is essentially an ERB template and a class whose
# instance servces as it's binding.
#
# The component has a few more smarts and helpers.
class Brut::Component
  class NullTemplateLocator
    def locate(base_name) = "SOMETHING IS WRONG NO LOCATOR WAS SET UP"
  end

  class TemplateLocator
    def initialize(path:, extension:)
      @path = Pathname(path)
      @extension = extension
    end

    def locate(base_name)
      @path / "#{base_name}.#{@extension}"
    end
  end

  # The component locator is used to locate the HTML/ERB of a component
  # used in the rendering if this component.  Rather than create one
  # out of the ether, new components are expected to be given
  # an instance to use.
  attr_writer :component_locator

  # SVGs can be included inline and a locator is used to do that. This is like
  # the `component_locator`
  attr_writer :svg_locator

  def initialize
    @component_locator = NullTemplateLocator.new
    @svg_locator       = NullTemplateLocator.new
  end

  # The core method of a component. This is expected to return
  # a string to be sent as a response to an HTTP request.
  #
  # This implementation uses the associated template for the component
  # and sends it through ERB using this component as
  # the binding.
  def render
    erb_file = @component_locator.locate(self.template_name)
    template = ERB.new(File.read(erb_file))
    template.location = [ erb_file.to_s, 1 ]

    scope = self.binding_scope
    template.result(scope)
  end

  # Helper methods that subclasses can use.
  # This is a separate module to distinguish the public
  # interface of this class (`render`) from these helper methods
  # that are useful to subclasses and their templates.
  module Helpers

    # Render a component. This is the primary way in which
    # view re-use happens.  The component instance will be able to locate its
    # HTML template and render itself.
    def component(component_instance)
      component_instance.component_locator = @component_locator
      component_instance.svg_locator       = @svg_locator
      component_instance.render
    end

    # Inline an SVG into the page.
    def svg(svg)
      svg_file = @svg_locator.locate(svg)
      File.read(svg_file)
    end
  end
  include Helpers

private

  def binding_scope = binding

  # Determines the canonical name/location of the template used for this
  # component.  It does this base do the class name. CameCase is converted
  # to snake_case. 
  def template_name = underscore(self.class.name).gsub(/^components\//,"")

  def underscore(string)
    return string.to_s.dup unless /[A-Z-]|::/.match?(string)
    word = string.to_s.gsub("::", "/")
    word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
