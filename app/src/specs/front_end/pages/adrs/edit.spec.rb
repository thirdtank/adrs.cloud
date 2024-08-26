require "spec_helper"
require "front_end/pages/adrs/edit"

RSpec.describe Pages::Adrs::Edit do
  context "error message" do
    it "shows the error message" do
      adr = create(:adr)
      page = described_class.new(adr: adr,
                                 error_message: "pages.adrs.edit.adr_cannot_be_accepted")

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      aside = html_locator.element!("aside[role='alert']")
      expect(aside.text.to_s.strip).to eq(page.t("pages.adrs.edit.adr_cannot_be_accepted"))
    end
  end
  context "updated message" do
    it "shows the updated message" do
      adr = create(:adr)
      page = described_class.new(adr: adr,
                                 updated_message: "actions.adrs.updated")

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      aside = html_locator.element!("aside[role='status']")
      expect(aside.text.to_s.strip).to eq(page.t("actions.adrs.updated"))
    end
  end
  context "replacing an ADR" do
    it "shows the ADR proposing to be replaced" do
      adr            = create(:adr, :accepted, accepted_at: nil)
      adr_to_replace = create(:adr, :accepted, account: adr.account)
      DataModel::ProposedAdrReplacement.create(
        replacing_adr_id: adr.id,
        replaced_adr_id: adr_to_replace.id,
        created_at: Time.now,
      )
      page = described_class.new(adr: adr)

      rendered_html = render_and_parse(page)
      expect(rendered_html.text).to include("Proposed Replacement for “#{adr_to_replace.title}”")
    end
  end
  context "refining an ADR" do
    it "shows the ADR being refined" do
      adr_being_refined = create(:adr, :accepted)
      adr               = create(:adr, account: adr_being_refined.account, refines_adr_id: adr_being_refined.id)

      page = described_class.new(adr: adr)

      rendered_html = render_and_parse(page)
      expect(rendered_html.text).to include("Refines “#{adr_being_refined.title}”")
    end
  end
end
