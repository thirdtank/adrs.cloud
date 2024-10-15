require "spec_helper"
RSpec.describe MarkdownStringComponent do
  it "renders an HTML safe string with HTML from the markdown, which has stripped HTML before rendering" do
    component = described_class.new("**This** is some <h1>markdown</h1>, `ok`?")

    rendered_html = component.render

    expect(rendered_html.class).to eq(Brut::FrontEnd::Templates::HTMLSafeString)
    expect(rendered_html.string.strip).to eq("<p><strong>This</strong> is some markdown, <code>ok</code>?</p>")
  end
  it "autolinks URLs it finds" do
    component = described_class.new("Check this out: https://example.com")

    rendered_html = component.render

    expect(rendered_html.string.strip).to eq("<p>Check this out: <a href=\"https://example.com\" class=\"blue-400\">https://example.com</a></p>")
  end
end
