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
