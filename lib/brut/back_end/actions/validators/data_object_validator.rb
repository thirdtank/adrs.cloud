class Brut::BackEnd::Actions::Validators::DataObjectValidator < Brut::BackEnd::Actions::Validator
  def self.validate(attribute,options)
    @@validations ||= {}
    @@validations[attribute] = options
  end

  def validate(object,check_result)
    @@validations.each do |attribute,options|
      value = object.send(attribute)
      options.each do |option, option_value|
        case option
        when :required
          if option_value == true
            if value.to_s.strip == ""
              check_result.constraint_violation!(object: object, field: attribute, key: :required)
            end
          end
        when :minlength
          if value.respond_to?(:length) || value.nil?
            if value.nil? || value.length < option_value
              check_result.constraint_violation!(object: object, field: attribute, key: :too_short, context: { minlength: option_value })
            end
          else
            raise "'#{attribute}''s value (a '#{value.class}') does not respond to 'length' - :minlength cannot be used as a validation"
          end
        else
          raise "'#{option}' is not a recognized validation option"
        end
      end
    end
  end

end
