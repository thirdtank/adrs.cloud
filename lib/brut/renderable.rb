require_relative "null_template_locator"

class Brut::Renderable
  attr_writer :component_locator

  def initialize
    @component_locator = Brut::NullTemplateLocator.new
  end

  def binding_scope = binding

  def component(component_instance)
    component_instance.component_locator = @component_locator
    erb_file = @component_locator.locate(component_instance.template_name)
    template = ERB.new(File.read(erb_file))

    scope = component_instance.binding_scope
    template.result(scope)
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
