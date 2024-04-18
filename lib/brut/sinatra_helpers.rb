require_relative "template_locator"

module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.set :components, Proc.new { root + "/view/components" }
    sinatra_app.set :pages,      Proc.new { root + "/view/pages" }
    sinatra_app.set :layouts,    Proc.new { root + "/view/layouts" }
  end

  def page(page_instance)
    layout_locator    = Brut::TemplateLocator.new(path: settings.layouts,    extension: "layout.erb")
    page_locator      = Brut::TemplateLocator.new(path: settings.pages,      extension: "page.erb")
    component_locator = Brut::TemplateLocator.new(path: settings.components, extension: "component.erb")

    page_instance.component_locator = component_locator
    layout_erb_file = layout_locator.locate(page_instance.layout)
    layout_template = ERB.new(File.read(layout_erb_file))

    erb_file = page_locator.locate(page_instance.template_name)
    template = ERB.new(File.read(erb_file))

    template_binding = page_instance.binding_scope do
      scope = page_instance.binding_scope
      template.result(scope)
    end
    layout_template.result(template_binding)
  end
end
