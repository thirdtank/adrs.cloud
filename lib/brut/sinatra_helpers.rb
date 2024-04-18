require_relative "template_locator"

module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.set :components, Proc.new { root + "/view/components" }
    sinatra_app.set :pages,      Proc.new { root + "/view/pages" }
    sinatra_app.set :layouts,    Proc.new { root + "/view/layouts" }
  end

  def page(page_instance)
    page_instance.layout_locator    = Brut::TemplateLocator.new(path: settings.layouts,    extension: "layout.erb")
    page_instance.page_locator      = Brut::TemplateLocator.new(path: settings.pages,      extension: "page.erb")
    page_instance.component_locator = Brut::TemplateLocator.new(path: settings.components, extension: "component.erb")

    page_instance.render
  end
end
