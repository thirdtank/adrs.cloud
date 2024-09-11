require "spec_helper"
RSpec.describe Adrs::ErrorMessagesComponent do
  module Spec
    class Form < Brut::FrontEnd::Form
      input :foo
    end
  end
  it "should show error message" do
    form = Spec::Form.new
    form.server_side_constraint_violation(input_name: "foo", key: :not_enough_words, context: { minwords: 10 })

    component = described_class.new(form:form)

    html = render_and_parse(component)
    locator = Support::HtmlLocator.new(html)

    element = locator.element!("brut-constraint-violation-message[input-name='foo']")
    expect(element.text.strip).to eq("This field must have at least 10 words")

  end
end
