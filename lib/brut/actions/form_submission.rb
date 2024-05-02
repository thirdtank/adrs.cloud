class Brut::Actions::FormSubmission < Brut::Action

  def initialize(client_side_validator: :default, server_side_validator: :default, action:)
    if client_side_validator == :default
      client_side_validator = Brut::Actions::Validators::ClientSideFormSubmissionValidator.new
    end
    if server_side_validator == :default
      server_side_validator = begin
                                action.class.const_get("ServerSideValidator").new
                              rescue NameError
                                Brut::Actions::NullValidator.new
                              end
    end
    @client_side_validator = client_side_validator
    @server_side_validator = server_side_validator
    @action                = action
  end

  def call(form_submission:, **rest)
    validation_errors = @client_side_validator.validate(form_submission:form_submission,**rest)
    if validation_errors.any?
      return { errors: validation_errors }
    end
    validation_errors = @server_side_validator.validate(form_submission:form_submission,**rest)
    if validation_errors.any?
      return { errors: validation_errors }
    end
    @action.call(form_submission: form_submission, **rest)
  end
end
