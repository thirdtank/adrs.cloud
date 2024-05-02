class Brut::Renderable
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

  attr_writer :component_locator
  attr_writer :svg_locator

  def initialize
    @component_locator = NullTemplateLocator.new
    @svg_locator       = NullTemplateLocator.new
  end

  def binding_scope = binding

  def component(component_instance)
    component_instance.component_locator = @component_locator
    component_instance.svg_locator       = @svg_locator
    component_instance.render
  end

  def svg(svg)
    svg_file = @svg_locator.locate(svg)
    File.read(svg_file)
  end

  def input_component_for(form_submission, input_name, html_input_type: :derive, html_attributes: {})
    default_html_attributes = {}
    input = form_submission[input_name]
    input_type = if html_input_type == :derive
                   input.html_input_type
                 else
                   html_input_type
                 end
    default_html_attributes["required"] = input.required?
    default_html_attributes["pattern"]  = input.pattern
    default_html_attributes["value"]    = form_submission.send(input_name)
    default_html_attributes["type"]     = input_type
    default_html_attributes["name"]     = input_name
    if input.minlength
      default_html_attributes["minlength"] = input.minlength
    end
    Brut::Components::Inputs::TextField.new(default_html_attributes.merge(html_attributes))
  end


private
  def underscore(string)
    return string.to_s.dup unless /[A-Z-]|::/.match?(string)
    word = string.to_s.gsub("::", "/")
    word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
