module Brut::Forms
  autoload(:ConformingValue, "brut/forms/conforming_value")
  autoload(:MissingValue, "brut/forms/missing_value")
  autoload(:NonConformingValue, "brut/forms/non_conforming_value")
  autoload(:InputDefinition, "brut/forms/input_definition")
end

# Mirrors a web browser's ValidityState API. Captures the overall state
# of validity of an input.
class Brut::Forms::ValidityState
  ATTRIBUTES = [
    :bad_input,
    :custom_error,
    :pattern_mismatch,
    :range_overflow,
    :range_underflow,
    :step_mismatch,
    :too_long,
    :too_short,
    :type_mismatch,
    :value_missing
  ]

  ATTRIBUTES.each do |attribute|
    define_method(attribute) do
      self.instance_variable_get("@#{attribute}")
    end
    define_method("#{attribute}?") do
      !!self.instance_variable_get("@#{attribute}")
    end
  end

  def custom_error=(message)
    @custom_error = message
    if message.to_s.strip == ""
      @custom_error = false
    end
    puts "Custom error is now '#{@custom_error}'"
    self.update_validity!
  end

  def initialize(errors={})
    unknown_attributes = errors.keys.select { |key| !ATTRIBUTES.include?(key) }
    if unknown_attributes.any?
      raise ArgumentError.new("#{self.class} does not recognize these attributes given to its constructor: #{unknown_attributes.join(', ')}")
    end
    errors.each do |key,value|
      self.instance_variable_set("@#{key}",value || false)
    end
    self.update_validity!
  end

  # Returns true if there are no validation errors
  def valid? = !!@valid

  def each(&block)
    ATTRIBUTES.each do |attribute|
      message = if attribute.to_s == "custom_error"
                  self.custom_error
                else
                  attribute.to_s.gsub(/_/," ")
                end
      block.call(attribute,self.send("#{attribute}?"),message)
    end
  end

private

  def update_validity!
    @valid = true
    ATTRIBUTES.each do |key|
      puts "Checking '#{key}'"
      value = self.send(key)
      puts "value is '#{value}'"
      if value
        puts "This shit is invalid"
        @valid = false
      end
    end
  end
end

module Brut::FussyTypeEnforcment
  def type!(value,type_descriptor,variable_name_for_error_message, required = false)

    if !required && value.nil?
      return value
    end

    if required &&
       (
         value.nil? ||
         (
           value.kind_of?(String) &&
           value.strip == ""
         )
       )
      raise ArgumentError.new("'#{variable_name_for_error_message}' must have a value")
    end

    if type_descriptor.kind_of?(Class)
      if !value.kind_of?(type_descriptor)
        raise ArgumentError.new("'#{variable_name_for_error_message}' must be a #{type_descriptor}, but was a #{value.class} (value as a string is #{value})")
      end
    elsif type_descriptor.kind_of?(Array)
      if !type_descriptor.include?(value)
        description_of_values = type_descriptor.map { |value|
          "#{value} (a #{value.class})"
        }.join(", ")
        raise ArgumentError.new("'#{variable_name_for_error_message}' must be one of #{description_of_values}, but was a #{value.class} (value as a string is #{value})")
      end
    else
      raise ArgumentError.new("Use of type! with a #{type_descriptor.class} (#{type_descriptor}) is not supported")
    end


    value
  end
end
# An Input represents an HTMLInput
class Brut::Forms::Input
  include Brut::FussyTypeEnforcment
  attr_reader :max,
              :maxlength,
              :min,
              :minlength,
              :name,
              :pattern,
              :required,
              :step,
              :type,
              :value,
              :validity_state

  INPUT_TYPES_TO_CLASS = {
    "checkbox"       => String,
    "color"          => String,
    "date"           => String,
    "datetime-local" => String,
    "email"          => String,
    "file"           => String,
    "hidden"         => String,
    "month"          => String,
    "number"         => Numeric,
    "password"       => String,
    "radio"          => String,
    "range"          => String,
    "search"         => String,
    "tel"            => String,
    "text"           => String,
    "time"           => String,
    "url"            => String,
    "week"           => String,
  }

  def initialize(
    max: nil,
    maxlength: nil,
    min: nil,
    minlength: nil,
    name: nil,
    pattern: nil,
    required: true,
    step: nil,
    type: nil
  )
    name = name.to_s
    type = if type.nil?
             case name
             when "email" then "email"
             when "password" then "password"
             end
           else
             type
           end

    @max       = type!( max       , Numeric       , "max")
    @maxlength = type!( maxlength , Numeric       , "maxlength")
    @min       = type!( min       , Numeric       , "min")
    @minlength = type!( minlength , Numeric       , "minlength")
    @name      = type!( name      , String        , "name")
    @pattern   = type!( pattern   , String        , "pattern")
    @required  = type!( required  , [true, false] , "required", :required)
    @step      = type!( step      , Numeric       , "step")
    @type      = type!( type      , INPUT_TYPES_TO_CLASS.keys,
                                                    "type", :required)

    if @pattern.nil? && type == "email"
      @pattern = /^[^@]+@[^@]+\.[^@]+$/.source
    end
    @validity_state = Brut::Forms::ValidityState.new
    @value = nil
  end

  def value=(new_value)
    missing = if @required
                new_value.nil? || (new_value.kind_of?(String) && new_value.strip == "")
              else
                false
              end
    too_short = if @minlength && !missing
                  new_value.length < @minlength
                else
                  false
                end
    @validity_state = Brut::Forms::ValidityState.new(
      value_missing: missing,
      too_short: too_short
    )
    @value = new_value
  end

  def set_custom_validity(error_message)
    @validity_state.custom_error = error_message
  end

  def dup
    duplicate = super
    duplicate.instance_variable_set("@validity_state",Brut::Forms::ValidityState.new)
    duplicate.instance_variable_set("@value",nil)
    duplicate
  end

  def valid? = @validity_state.valid?

end

# A Form is a server-side representation of an HTML form, with the ability 
# to be enhanced with server-side logic and information.
#
# While this class does not have an exact replica of the HTMLFormElement
# API, it mirrors what is needed to a) render the form server side, and b)
# process a form submission.
#
# At its core, a Form is a collection of Inputs.  These are available
# via the `#elements` method, and should be of type Brut::Input.
#
# The easiest way to create a Form is to subclass it for your use-case, and
# call the class method `input` for each input in the form.
class Brut::Form
  def self.input(name,attributes={})
    input = Brut::Forms::Input.new(**(attributes.merge(name: name)))
    @inputs ||= {}
    @inputs[input.name] = input
  end

  def self.inputs = @inputs

  # Create an instance of this form, optionally initialized with
  # the given values for its params.
  def initialize(params = nil)
    @new = params.nil?
    params ||= {}
    unknown_params = params.keys.map(&:to_s).reject { |key|
      self.class.inputs.key?(key)
    }
    if unknown_params.any?
      puts "Ignoring params: #{unknown_params}"
    end
    @inputs = self.class.inputs.map { |name,input|
      dup_input = input.dup
      puts "Setting value of #{name} to #{params[name] || params[name.to_sym]}"
      dup_input.value = params[name] || params[name.to_sym]
      self.class.define_method name do
        dup_input.value
      end
      [ name, dup_input ]
    }.to_h
    puts @inputs.inspect
    puts @inputs["email"].value
  end

  # Returns true if this form represents a new, empty, untouched form. This is
  # useful for determining if this form has never been submitted and thus
  # any required values don't represent an intentional omission by the user.
  def new? = @new

  def elements = @inputs.values
  def [](input_name) = @inputs.fetch(input_name.to_s)

  def valid? = self.elements.all?(&:valid?)


end
