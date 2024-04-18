require_relative "renderable"
require_relative "null_template_locator"

class Brut::BasePage < Brut::Renderable
  attr_reader :content, :errors

  def initialize(content: {}, errors: [])
    @content = content
    @errors  = errors
    @component_locator = Brut::NullTemplateLocator.new
  end
  def errors? = !@errors.empty?

  def template_name = underscore(self.class.name).gsub(/^pages\//,"")
  def layout = "default"
end

