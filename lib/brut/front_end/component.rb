require "json"
require_relative "template"

module Brut::FrontEnd::Components
  autoload(:Form,"brut/front_end/components/form")
  autoload(:Input,"brut/front_end/components/input")
  autoload(:Inputs,"brut/front_end/components/input")
end
# A Component is the top level class for managing the rendering of 
# content.  A component is essentially an ERB template and a class whose
# instance servces as it's binding.
#
# The component has a few more smarts and helpers.
class Brut::FrontEnd::Component
  extend Brut::Container::Uses

  uses :component_locator
  uses :svg_locator
  uses :asset_path_resolver

  class TemplateLocator
    def initialize(path:, extension:)
      @path = Pathname(path)
      @extension = extension
    end

    def locate(base_name)
      @path / "#{base_name}.#{@extension}"
    end
  end

  class AssetPathResolver
    def initialize(metadata_file:)
      @metadata = JSON.parse(File.read(metadata_file))["asset_metadata"]
      if @metadata.nil?
        raise "Asset metadata file '#{metadata_file}' is corrupted. There is no top-level 'asset_metadata' key"
      end
    end

    def resolve(path)
      extension = File.extname(path)
      if @metadata[extension]
        if @metadata[extension][path]
          @metadata[extension][path]
        else
          raise "Asset metadata does not have a mapping for '#{path}'"
        end
      else
        raise "Asset metadata has not been set up for files with extension '#{extension}'"
      end
    end
  end

  # The core method of a component. This is expected to return
  # a string to be sent as a response to an HTTP request.
  #
  # This implementation uses the associated template for the component
  # and sends it through ERB using this component as
  # the binding.
  def render
    erb_file = self.component_locator.locate(self.template_name)
    template = Brut::FrontEnd::Template.new(erb_file)
    Brut::FrontEnd::Templates::HTMLSafeString.from_string(
      template.render_template(self)
    )
  end

  # Helper methods that subclasses can use.
  # This is a separate module to distinguish the public
  # interface of this class (`render`) from these helper methods
  # that are useful to subclasses and their templates.
  #
  # This is not intended to be extracted or used outside this class!
  module Helpers

    # Render a component. This is the primary way in which
    # view re-use happens.  The component instance will be able to locate its
    # HTML template and render itself.
    def component(component_instance)
      call_render = CallRenderInjectingInfo.new(component_instance)
      Brut::FrontEnd::Templates::HTMLSafeString.from_string(
        call_render.call_render(**Thread.current[:rendering_context])
      )
    end

    # Inline an SVG into the page.
    def svg(svg)
      svg_file = self.svg_locator.locate(svg)
      Brut::FrontEnd::Templates::HTMLSafeString.from_string(File.read(svg_file))
    end

    # Given a public path to an asset—the value you'd use in HTML—return
    # the same value, but with any content hashes that are part of the filename.
    def asset_path(path) = self.asset_path_resolver.resolve(path)

    # Render a form that should include CSRF protection.
    def form_tag(**attributes,&block)
      component(Brut::FrontEnd::Components::Form.new(**attributes,&block))
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
