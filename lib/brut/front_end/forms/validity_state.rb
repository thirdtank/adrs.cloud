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

