require "rexml"
# Represents a <form> HTML component
class Brut::FrontEnd::Components::Form < Brut::FrontEnd::Component
  def initialize(**attributes,&contents)
    @attributes = attributes
    @contents = contents
  end

  def render
    attribute_string = @attributes.map { |key,value|
      key = key.to_s
      if value == true
        key
      elsif value == false
        ""
      else
        REXML::Attribute.new(key,value).to_string
      end
    }.join(" ")
    %{
      <form #{attribute_string}>
        #{ component(Brut::FrontEnd::Components::Inputs::CsrfToken.new) }
        #{ @contents.() }
      </form>
    }
  end
end
