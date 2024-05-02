class Brut::Actions::Validators::ClientSideFormSubmissionValidator < Brut::Actions::Validator
  def validate(form_submission:, **rest)
    if form_submission.valid?
      {}
    else
      form_submission.validation_errors
    end
  end
end
