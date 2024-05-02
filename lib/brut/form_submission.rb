module Brut::FormSubmissions
  autoload(:ConformingValue, "brut/form_submissions/conforming_value")
  autoload(:MissingValue, "brut/form_submissions/missing_value")
  autoload(:NonConformingValue, "brut/form_submissions/non_conforming_value")
  autoload(:InputDefinition, "brut/form_submissions/input_definition")
end
class Brut::FormSubmission

  def [](name)
    self.class.inputs.fetch(name.to_s)
  end

  def self.input(name,type=String,options={})
    if (options.nil? || options.empty?) && type.kind_of?(Hash)
      options = type
      type = String
    end

    @inputs ||= {}
    input_definition = Brut::FormSubmissions::InputDefinition.new(name,type,options)
    @inputs[input_definition.name] = input_definition

    define_method input_definition.name do
      self.send("_wrapped_#{input_definition.name}").value
    end

    define_method "_wrapped_#{input_definition.name}" do
      instance_variable_get("@#{input_definition.name}")
    end

    define_method "#{input_definition.name}=" do |raw_val|
      input_def = self.class.inputs[input_definition.name]
      wrapper = if raw_val.nil?
                  if input_def.required?
                    Brut::FormSubmissions::MissingValue.new
                  else
                    Brut::FormSubmissions::ConformingValue.new(nil)
                  end
                else
                  if raw_val == "" || (raw_val.to_s.strip == "" && input_def.type == String)
                    if input_def.required?
                      Brut::FormSubmissions::MissingValue.new
                    else
                      Brut::FormSubmissions::ConformingValue.new(nil)
                    end
                  else
                    begin
                      Brut::FormSubmissions::ConformingValue.new(input_def.type.new(raw_val))
                    rescue ArgumentError => ex
                      Brut::FormSubmissions::NonConformingValue.new(raw_val,ex)
                    end
                  end
                end
      instance_variable_set("@#{input_definition.name}",wrapper)
    end
  end

  def self.inputs
    @inputs || {}
  end

  def initialize(inputs={})
    @new = inputs.keys.empty?
    self.class.inputs.each do |(attr,metadata)|
      val = inputs[attr.to_s] || inputs[attr.to_sym]
      self.send("#{attr}=",val)
    end
  end

  def validation_errors
    self.class.inputs.map { |(attr)|
      [ attr, self.send("_wrapped_#{attr}") ]
    }.reject { |(_,wrapped_value)|
      wrapped_value.conforming?
    }.map { |(attr,wrapped_value)|
      [ attr, "#{attr} is #{wrapped_value.error}" ]
    }.to_h
  end

  def valid? = validation_errors.keys.none?

  def validate!
    errors = self.validation_errors
    if errors.any?
      raise errors.values.join(",")
    end
  end

  def new? = @new

end
