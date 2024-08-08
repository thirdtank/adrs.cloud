module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.set :logging, false
  end

  def page(page_instance)
    call_render = CallRenderInjectingInfo.new(page_instance)
    call_render.call_render(csrf_token: Rack::Protection::AuthenticityToken.token(env["rack.session"]))
  end

  def process_form(form:, action:, **rest)
    SemanticLogger["SinatraHelpers"].info("Processing form",
                                        form: form.class,
                                        action: action.class,
                                        params: form.to_h)
    action = Brut::BackEnd::Actions::FormSubmission.new(action: action)
    result = action.call(form: form, **rest)
    case result
    in Brut::BackEnd::Actions::CheckResult if !result.can_call?
      result.each_violation do |object,field,key,context|
        if object == form
          form.server_side_constraint_violation(input_name: field, key: key, context: context)
        end
      end
      if form.valid?
        raise "WTF: Form is valid??!?!?"
      end
      form
    else
      result
    end
  end
end
