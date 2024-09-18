require "rexml"
class Brut::FrontEnd::Components::PageIdentifier < Brut::FrontEnd::Component
  def initialize(page_name)
    @page_name = page_name
  end

  def render
    if Brut.container.project_env.production?
      return ""
    end
    value_attribute = REXML::Attribute.new("content",@page_name).to_string
    "<meta name=\"class\" #{value_attribute}>"
  end
end
