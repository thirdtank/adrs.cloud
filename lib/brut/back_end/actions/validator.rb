module Brut::BackEnd::Actions::Validators
  autoload(:DataObjectValidator, "brut/back_end/actions/validators/data_object_validator")
end

class Brut::BackEnd::Actions::Validator
  def validate(*args)
    {}
  end

end
