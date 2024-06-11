class Brut::Actions::FormSubmission < Brut::Action

  def initialize(action:)
    @action = action
  end

  def check(form:, **rest)
    if form.invalid?
      return self.not_callable(form: form)
    end
    @action.check(form: form, **rest)
  end

  def call(form:, **rest)
    if form.invalid?
      return form
    end
    result = @action.check(form: form, **rest)
    if result.can_call?
      @action.call(form: form, **rest)
    else
      result
    end
  end
end
