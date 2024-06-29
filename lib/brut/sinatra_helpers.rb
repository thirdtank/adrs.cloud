module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.set :components,     Proc.new { root + "/src/view/components" }
    sinatra_app.set :svgs,           Proc.new { root + "/src/view/svgs" }
    sinatra_app.set :pages,          Proc.new { root + "/src/view/pages" }
    sinatra_app.set :layouts,        Proc.new { root + "/src/view/layouts" }
    sinatra_app.set :asset_metadata, Proc.new { root + "/config/asset_metadata.json" }
    sinatra_app.set :logging, false
  end

  def page(page_instance)
    page_instance.layout_locator    = Brut::Component::TemplateLocator.new(path: settings.layouts,    extension: "html.erb")
    page_instance.page_locator      = Brut::Component::TemplateLocator.new(path: settings.pages,      extension: "html.erb")
    page_instance.component_locator = Brut::Component::TemplateLocator.new(path: settings.components, extension: "html.erb")
    page_instance.svg_locator       = Brut::Component::TemplateLocator.new(path: settings.svgs,       extension: "svg")

    page_instance.asset_path_resolver = Brut::Component::AssetPathResolver.new(metadata_file: settings.asset_metadata)

    page_instance.render
  end

  def process_form(form:, action:, **rest)
    SemanticLogger["SinatraHelpers"].info("Processing form",
                                        form: form.class,
                                        action: action.class,
                                        params: form.to_h)
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
