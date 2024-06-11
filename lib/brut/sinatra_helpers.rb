module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.set :components, Proc.new { root + "/view/components" }
    sinatra_app.set :svgs,       Proc.new { root + "/view/svgs" }
    sinatra_app.set :pages,      Proc.new { root + "/view/pages" }
    sinatra_app.set :layouts,    Proc.new { root + "/view/layouts" }
  end

  def page(page_instance)
    page_instance.layout_locator    = Brut::Renderable::TemplateLocator.new(path: settings.layouts,    extension: "html.erb")
    page_instance.page_locator      = Brut::Renderable::TemplateLocator.new(path: settings.pages,      extension: "html.erb")
    page_instance.component_locator = Brut::Renderable::TemplateLocator.new(path: settings.components, extension: "html.erb")
    page_instance.svg_locator       = Brut::Renderable::TemplateLocator.new(path: settings.svgs,       extension: "svg")

    page_instance.render
  end

  def process_form(form:, action:, **rest)
    action = Brut::Actions::FormSubmission.new(action: action)
    result = action.call(form: form, **rest)
    case result
    in Brut::Actions::CheckResult if !result.can_call?
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
