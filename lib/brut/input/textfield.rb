require_relative "../input"
require_relative "../base_component"
class Brut::Input::TextField < Brut::BaseComponent
  def initialize(attributes: {}, form:, input:, type:)
    @sanitized_attributes = attributes.map { |key,value|
        [
          key.to_s.gsub(/[\s\"\'>\/=]/,"-"),
          value
        ]
    }.to_h.merge({
      "required" => form.class.inputs[input].required?,
      "name" => input,
      "value" => form.send(input),
    })
    @type = type
  end

  def render
    attribute_string = @sanitized_attributes.map { |key,value|
      if value == true
        key
      elsif value == false
        ""
      else
        REXML::Attribute.new(key,value).to_string
      end
    }.join(" ")
    %{
      <input type="#{@type}" #{attribute_string}>
    }
  end
end
