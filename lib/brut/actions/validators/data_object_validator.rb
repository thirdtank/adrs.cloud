class Brut::Actions::Validators::DataObjectValidator < Brut::Actions::Validator
  def self.validate(attribute,options)
    @@validations ||= {}
    @@validations[attribute] = options
  end

  def validate(object)
    @@validations.map { |attribute,options|
      value = object.send(attribute)
      errors = options.map { |option, option_value|
        case option
        when :required
          if option_value == true
            if value.to_s.strip == ""
              "is required"
            else
              nil
            end
          end
        when :minlength
          if value.respond_to?(:length) || value.nil?
            if value.nil? || value.length < option_value
              "must be at least '#{option_value}' long"
            else
              nil
            end
          else
            raise "'#{attribute}''s value (a '#{value.class}') does not respond to 'length' - :minlength cannot be used as a validation"
          end
        else
          raise "'#{option}' is not a recognized validation option"
        end
      }.compact

      if errors.any?
        [ attribute, errors ]
      else
        nil
      end
    }.compact.to_h
  end

end
