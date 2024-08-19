module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.set :logging, true
    sinatra_app.before do
      Thread.current[:rendering_context] = {
        csrf_token: Rack::Protection::AuthenticityToken.token(env["rack.session"])
      }
      session[:_flash] ||= {
        age: 0,
        messages: {}
      }
    end
    sinatra_app.after do
      Thread.current[:rendering_context] = nil
      session[:_flash][:age] += 1
      if session[:_flash][:age] > 2
        session[:_flash] = {
          age: 0,
          messages: {}

        }
      end
    end
  end

  def flash
    session[:_flash][:messages]
  end

  def page(page_instance)
    call_render = CallRenderInjectingInfo.new(page_instance)
    call_render.call_render(**Thread.current[:rendering_context])
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
          context ||= {}
          humanized_field = RichString.new(field).humanized.to_s
          form.server_side_constraint_violation(input_name: field, key: key, context: context.merge(field: humanized_field))
        end
      end
      if form.valid?
        raise "WTF: Form is valid??!?!?"
      end
      form.server_side_context = result.context
      form
    else
      result
    end
  end
end
