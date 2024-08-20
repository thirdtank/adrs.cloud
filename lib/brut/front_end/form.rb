require "forwardable"

# Brut Forms
#
# Brut's form handling mirrors HTML and the browser as much as it can, but accomodates the notion of server-side validation and
# processing.  Brut attempts to rely as much on standard APIs as possible.
#
# At a high level, the form and its inputs are declared server side in a Brut::FrontEnd::Form subclass, which is used to render HTML
# that includes constraint validations.  These validations are used by the browser to prevent submission of invalid data.  You
# can use CSS and server-rendered HTML to control how errors are presented, using standard web APIs.
#
# When the form is submitted to the server, the client side validations are re-checked. If they pass, any optional server-side
# validations are run.  If either client or server validations fail, the form object contains information on the failures. This
# can be used to re-render the form to show the user the errrors.
#
# When the validations all pass, the form is handed off to A Brut::BackEnd::Action subclass you provide.

module Brut::FrontEnd::Forms
  autoload(:ConformingValue, "brut/front_end/forms/conforming_value")
  autoload(:MissingValue, "brut/front_end/forms/missing_value")
  autoload(:NonConformingValue, "brut/front_end/forms/non_conforming_value")
  autoload(:InputDefinition, "brut/front_end/forms/input_definition")
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

# A constraint, which is a wrapper for a key that represents a type of error, along with context about
# the error.  A constraint knows if it's a client side constraint or not.
class Brut::FrontEnd::Forms::Constraint

  CLIENT_SIDE_KEYS = [
    "bad_input",
    "custom_error",
    "pattern_mismatch",
    "range_overflow",
    "range_underflow",
    "step_mismatch",
    "too_long",
    "too_short",
    "type_mismatch",
    "value_missing",
  ]

  attr_reader :key, :context

  def initialize(key:,context:, server_side: :based_on_key)
    @key = key.to_s
    @client_side = CLIENT_SIDE_KEYS.include?(@key) && server_side != true
    @context = context || {}
    if !@context.kind_of?(Hash)
      raise "#{self.class} created for key #{key} with an invalid context: '#{context}/#{context.class}'. Context must be nil or a hash"
    end
  end

  def client_side? = @client_side
  def to_s = @key
end

# Mirrors a web browser's ValidityState API. Captures the overall state
# of validity of an input.  This can accomodate server-side constraint violations
# that are essentially arbitrary.  This means that an instance of this class should
# fully capture all constraint violations for a given field.  You can 
# iterate over all the violations with #each, which will yield one `Constraint` for
# each failure.  You can query the constraint to determine if it is a client side constraint or not.
class Brut::FrontEnd::Forms::ValidityState
  include Enumerable

  # Creates a validity state with the given errors.
  #
  # ::constraint_violations - an array of symbols or strings that represent the keys of each constraint violation.
  #                           These keys are used to render human-readable strings. The values are true or false if
  #                           the key is currently in violation.
  def initialize(constraint_violations={})
    @constraint_violations = constraint_violations.map { |key,value|
      if value
        Brut::FrontEnd::Forms::Constraint.new(key: key, context: {})
      else
        nil
      end
    }.compact
  end

  # Returns true if there are no validation errors
  def valid? = @constraint_violations.empty?

  # Set a server-side constraint violation. This is essentially arbitrary and dependent
  # on your use-case.
  def server_side_constraint_violation(key:,context:)
    @constraint_violations << Brut::FrontEnd::Forms::Constraint.new(key: key, context: context, server_side: true)
  end

  def each(&block)
    @constraint_violations.each do |constraint|
      block.call(constraint)
    end
  end

end

# An InputDefinition captures metadata used to create an Input. Think of this
# as a template for creating inputs.  An Input has state, such as values and thus validity.
# An InputDefinition is immutable and defines inputs.
class Brut::FrontEnd::Forms::InputDefinition
  include Brut::FussyTypeEnforcment
  attr_reader :max,
              :maxlength,
              :min,
              :minlength,
              :name,
              :pattern,
              :required,
              :step,
              :type

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

  # Create an InputDefinition. This should very closely mirror
  # the attributes used in an <INPUT> element in HTML.
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
             else
               "text"
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
  end

  # Create an Input based on this defitition, initializing it with the given value.
  def make_input(value:)
    Brut::FrontEnd::Forms::Input.new(input_definition: self, value: value)
  end
end

# An Input is a stateful object representing a specific input and its value
# during the course of a form submission process. In particular, it wraps a value
# and a ValidityState. These are mutable, whereas the wrapped InputDefinition is not.
class Brut::FrontEnd::Forms::Input

  extend Forwardable

  attr_reader :value, :validity_state

  def initialize(input_definition:, value:)
    @input_definition = input_definition
    @validity_state = Brut::FrontEnd::Forms::ValidityState.new
    self.value=(value)
  end

  def_delegators :"@input_definition", :max,
                                       :maxlength,
                                       :min,
                                       :minlength,
                                       :name,
                                       :pattern,
                                       :required,
                                       :step,
                                       :type

  def value=(new_value)
    missing = if self.required
                new_value.nil? || (new_value.kind_of?(String) && new_value.strip == "")
              else
                false
              end
    too_short = if self.minlength && !missing
                  new_value.length < self.minlength
                else
                  false
                end
    @validity_state = Brut::FrontEnd::Forms::ValidityState.new(
      value_missing: missing,
      too_short: too_short
    )
    @value = new_value
  end

  # Set a server-side constraint violation on this input.  This is essentially arbitrary, but note
  # that `key` should not be a key used for client-side validations.
  def server_side_constraint_violation(key,context=true)
    @validity_state.server_side_constraint_violation(key: key, context: context)
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
# via the `#elements` method, and should be of type Brut::FrontEnd::Input.
#
# The easiest way to create a Form is to subclass it for your use-case, and
# call the class method `input` for each input in the form.
#
# If you do this, your form will have accessors for each input that return the
# value of that form input. You can access the Input via []
class Brut::FrontEnd::Form

  include SemanticLogger::Loggable

  def self.input(name,attributes={})
    input_definition = Brut::FrontEnd::Forms::InputDefinition.new(**(attributes.merge(name: name)))
    @input_definitions ||= {}
    @input_definitions[input_definition.name] = input_definition
    define_method name do
      self[name].value
    end
  end

  def self.input_definitions = @input_definitions

  # Create an instance of this form, optionally initialized with
  # the given values for its params.
  def initialize(params = nil)
    params ||= {}
    unknown_params = params.keys.map(&:to_s).reject { |key|
      self.class.input_definitions.key?(key)
    }
    if unknown_params.any?
      logger.warn "Ignoring unknown params", keys: unknown_params
    end
    @new = params_empty?(params.except(*unknown_params))
    @inputs = self.class.input_definitions.map { |name,input_definition|
      input = input_definition.make_input(value: params[name] || params[name.to_sym])
      [ name, input ]
    }.to_h
  end

  # Set context from a server call that may be needed by the front-end
  def server_side_context=(context)
    @context = context || {}
  end

  # Retreive any server-side context that was provided. Never returns nil.
  def server_side_context
    @context || {}
  end

  # Returns true if this form represents a new, empty, untouched form. This is
  # useful for determining if this form has never been submitted and thus
  # any required values don't represent an intentional omission by the user.
  def new? = @new

  def elements = @inputs.values
  def [](input_name) = @inputs.fetch(input_name.to_s)

  def valid?   = self.elements.all?(&:valid?)
  def invalid? = !self.valid?

  # Set a server-side constraint violation on a given input's name.
  def server_side_constraint_violation(input_name:, key:, context:{})
    self[input_name].server_side_constraint_violation(key,context)
  end

  def to_h
    @inputs.map { |name,input| [ name, input.value ] }.to_h
  end

  def constraint_violations(server_side_only: false)
    @inputs.map { |input_name, input|
      if input.valid?
        nil
      else
        [
          input_name,
          input.validity_state.select { |constraint|
            if server_side_only
              !constraint.client_side?
            else
              true
            end
          }
        ]
      end
    }.compact.to_h
  end

private

  def params_empty?(params) = params.nil? || params.empty?

end
