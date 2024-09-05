require "spec_helper"

RSpec.describe NewDraftAdrPage do
  context "form is invalid" do
    it "shows the error message" do
      account = create(:account)
      form = NewDraftAdrForm.new(params: { title: "AAA" })
      form.server_side_constraint_violation(input_name: "title", key: :required)

      page = described_class.new(form: form, account: account)

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      element = html_locator.element!("aside[role='alert']")
      expect(element.text.to_s.strip).to eq(page.t(:adr_invalid))
    end
  end
  context "form is valid but blank" do
    it "does not show the error message" do
      account = create(:account)
      form = NewDraftAdrForm.new

      page = described_class.new(form: form, account: account)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("aside[role='alert']").size).to eq(0)
    end
  end

end
