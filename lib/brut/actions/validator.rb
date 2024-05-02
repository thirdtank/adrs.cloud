module Brut::Actions::Validators
  autoload(:ClientSideFormSubmissionValidator, "brut/actions/validators/client_side_form_submission_validator")
  autoload(:NullValidator, "brut/actions/validators/null_validator")
  autoload(:DataObjectValidator, "brut/actions/validators/data_object_validator")
end

class Brut::Actions::Validator
  def validate(*args)
    {}
  end

end
