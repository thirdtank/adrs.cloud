# A page is a component that has a layout and thus is intended to be
# an entire web page, not just a fragment.
class Brut::FrontEnd::Page < Brut::FrontEnd::Component
  uses :layout_locator
  uses :page_locator

  def layout = "default"

  # Overrides component's render to add the concept of a layout.
  # A layout is an HTML/ERB file that will contain this page's contents.
  def render
    layout_erb_file = self.layout_locator.locate(self.layout)
    layout_template = Brut::FrontEnd::Template.new(layout_erb_file)

    erb_file = self.page_locator.locate(self.template_name)
    template = Brut::FrontEnd::Template.new(erb_file)
    layout_template.render_template(self) do
      Brut::FrontEnd::Templates::HTMLSafeString.from_string(
        template.render_template(self)
      )
    end
  end

private

  def template_name = RichString.new(self.class.name).underscorized.to_s.gsub(/^pages\//,"")
end

