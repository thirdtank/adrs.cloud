class Brut::Components::Inputs::Textarea < Brut::Components::Input
  def initialize(attributes: {}, form:, input:)
    @sanitized_attributes = attributes.map { |key,value|
        [
          key.to_s.gsub(/[\s\"\'>\/=]/,"-"),
          value
        ]
    }.to_h.merge({
      "required" => form.class.inputs[input].required?,
      "name" => input,
    })
    @value = form.send(input)
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
      <textarea #{attribute_string}>#{ @value }</textarea>
    }
  end
end
