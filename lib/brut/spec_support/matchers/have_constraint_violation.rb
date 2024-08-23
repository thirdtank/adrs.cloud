RSpec::Matchers.define :have_constraint_violation do |field,object:,key:|
  match do |result|
    Brut::SpecSupport::Matchers::HaveConstraintViolation.new(result,field,object,key).matches?
  end

  failure_message do |result|
    analysis = Brut::SpecSupport::Matchers::HaveConstraintViolation.new(result,field,object,key)
    if analysis.found_object?
      if analysis.found_field?
        "#{field} did not have #{key} as a violation.  These keys were found: #{analysis.keys_on_field_found.map(&:to_s).join(", ")}"
      else
        "#{field} had no errors.  These fields DID: #{analysis.fields_found.map(&:to_s).join(", ")}"
      end
    else
      "Did not find the object on which violations were attached in the result"
    end
  end

  failure_message_when_negated do |result|
    "Found #{key} as a violation on #{field}"
  end
end

class Brut::SpecSupport::Matchers::HaveConstraintViolation
  attr_reader :fields_found
  attr_reader :keys_on_field_found

  def initialize(result, field, object, key)
    @result = result
    @field  = field
    @object = object
    @key    = key

    @matches             = false
    @found_object        = false
    @found_field         = false
    @fields_found        = Set.new
    @keys_on_field_found = Set.new

    @result.each_violation do |object,field,key,_context|
      if object == @object
        @found_object = true
        if field == @field
          @found_field = true
          if key == @key
            @matches = true
          else
            @keys_on_field_found << key
          end
        else
          @fields_found << field
        end
      end
    end
  end

  def matches?      = @matches
  def found_object? = @found_object
  def found_field?  = @found_field

end
