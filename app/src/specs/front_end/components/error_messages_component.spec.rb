require "spec_helper"
RSpec.describe ErrorMessagesComponent do
  it "should show error message" do
    form = Class.new(Brut::FrontEnd::Form) {
      input :foo
    }.new

    form.server_side_constraint_violation(input_name: "foo", key: :not_enough_words, context: { minwords: 10 })

    component = described_class.new(form:form)

    html = render_and_parse(component)
    locator = Support::HtmlLocator.new(html)
    expect(html.name).to eq("brut-constraint-violation-message")
    expect(html).to have_html_attribute("input-name" => "foo")
    expect(html.text.strip).to eq("This field must have at least 10 words")

  end
end
