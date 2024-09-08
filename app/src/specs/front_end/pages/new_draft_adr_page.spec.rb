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
  context "refining another ADR" do
    it "shows that ADR's title" do
      adr_being_refined = create(:adr, :accepted)
      account = adr_being_refined.account
      form = NewDraftAdrForm.new(params: { refines_adr_external_id: adr_being_refined.external_id })

      page = described_class.new(form: form, account: account)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("aside[role='alert']").size).to eq(0)
      expect(rendered_html.text).to include(adr_being_refined.title)
    end
  end
  context "proposing to replace another ADR" do
    it "shows that ADR's title" do
      adr_being_replaced = create(:adr, :accepted)
      account = adr_being_replaced.account
      form = NewDraftAdrForm.new(params: { replaced_adr_external_id: adr_being_replaced.external_id })

      page = described_class.new(form: form, account: account)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("aside[role='alert']").size).to eq(0)
      expect(rendered_html.text).to include(adr_being_replaced.title)
    end
  end

end
