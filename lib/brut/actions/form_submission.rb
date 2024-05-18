class Brut::Actions::FormSubmission < Brut::Action

  def initialize(server_side_validator: :default, action:)
    if server_side_validator == :default
      server_side_validator = begin
                                action.class.const_get("ServerSideValidator").new
                              rescue NameError
                                Brut::Actions::NullValidator.new
                              end
    end
    @server_side_validator = server_side_validator
    @action                = action
  end

  def call(form:, **rest)
    if form.invalid?
      return form
    end
    @server_side_validator.validate(form:form,**rest)
    if form.invalid?
      return form
    end
    @action.call(form: form, **rest)
  end
end
