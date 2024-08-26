require "spec_helper"
require "front_end/pages/adrs/new"

RSpec.describe Pages::Adrs::New do
  context "form is invalid" do
    it "shows the error message" do
      form = Forms::Adrs::Draft.new(title: "AAA")
      form.server_side_constraint_violation(input_name: "title", key: :required)

      page = described_class.new(form: form)

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      element = html_locator.element!("aside[role='alert']")
      expect(element.text.to_s.strip).to eq("ADR is invalid. See below")
    end
  end
  context "form is valid but blank" do
    it "does not show the error message" do
      form = Forms::Adrs::Draft.new

      page = described_class.new(form: form)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("aside[role='alert']").size).to eq(0)
    end
  end

end
