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
  def component(component_instance)
    self.page(component_instance)
  end

  def process_form(form:, action:, action_method: :call, **rest)
    SemanticLogger["SinatraHelpers"].info("Processing form",
                                        form: form.class,
                                        action: action.class,
                                        action_method: action_method,
                                        params: form.to_h)
    form_submission = Brut::BackEnd::Actions::FormSubmission.new
    form_submission.process_form(form: form,
                                 action: action,
                                 action_method: action_method,
                                 **rest)
  end
end
