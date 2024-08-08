require "erb"

# A page is a component that has a layout and thus is intended to be
# an entire web page, not just a fragment.
class Brut::FrontEnd::Page < Brut::FrontEnd::Component
  uses :layout_locator
  uses :page_locator

  def layout = "default"

  # Overrides component's render to add the concept of a layout.
  # A layout is an HTML/ERB file that will contain this page's contents.
  def render(csrf_token: nil)
    @rendering_context = {
      csrf_token: csrf_token
    }
    layout_erb_file = self.layout_locator.locate(self.layout)
    layout_template = ERB.new(File.read(layout_erb_file))
    layout_template.location = [ layout_erb_file.to_s, 1 ]

    erb_file = self.page_locator.locate(self.template_name)
    template = ERB.new(File.read(erb_file))
    template.location = [ erb_file.to_s, 1 ]

    template_binding = self.binding_scope do
      scope = self.binding_scope
      scope.local_variable_set(:csrf_token, csrf_token)
      template.result(scope)
    end
    layout_template.result(template_binding)
  ensure
    @rendering_context = {}
  end

private

  def template_name = underscore(self.class.name).gsub(/^pages\//,"")
end

