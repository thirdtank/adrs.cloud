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
    layout_template = Brut::FrontEnd::Template.new(layout_erb_file)

    erb_file = self.page_locator.locate(self.template_name)
    template = Brut::FrontEnd::Template.new(erb_file)
    layout_template.render(self, csrf_token: csrf_token) do
      Brut::FrontEnd::Template::SafeString.from_string(template.render(self, csrf_token: csrf_token))
    end
  ensure
    @rendering_context = {}
  end

private

  def template_name = underscore(self.class.name).gsub(/^pages\//,"")
end

