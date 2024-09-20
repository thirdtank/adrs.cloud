require "spec_helper"

RSpec.describe EditDraftAdrByExternalIdPage do
  context "error message" do
    it "shows the error message" do
      adr = create(:adr)
      page = described_class.new(account: adr.account, external_id: adr.external_id,
                                 flash: flash_from(error: :adr_cannot_be_accepted))

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      aside = html_locator.element!("aside[role='alert']")
      expect(aside.text.to_s.strip).to eq(page.t(:adr_cannot_be_accepted))
    end
  end
  context "form with errors" do
    it "shows the errors" do
      adr  = create(:adr, :accepted, accepted_at: nil)
      form = EditDraftAdrWithExternalIdForm.new(params: { external_id: adr.external_id, title: "aa" })

      page = described_class.new(account: adr.account, external_id: adr.external_id, form: form, flash: empty_flash)

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      expect(html_locator.element!("input[name=title][data-invalid]")).not_to eq(nil)
    end
  end
  context "replacing an ADR" do
    it "shows the ADR proposing to be replaced" do
      adr            = create(:adr, :accepted, accepted_at: nil)
      adr_to_replace = create(:adr, :accepted, account: adr.account)
      DB::ProposedAdrReplacement.create(
        replacing_adr_id: adr.id,
        replaced_adr_id: adr_to_replace.id,
        created_at: Time.now,
      )
      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      rendered_html = render_and_parse(page)
      expect(rendered_html.text).to include("Proposed Replacement for “#{adr_to_replace.title}”")
    end
  end
  context "refining an ADR" do
    it "shows the ADR being refined" do
      adr_being_refined = create(:adr, :accepted)
      adr               = create(:adr, account: adr_being_refined.account, refines_adr_id: adr_being_refined.id)

      page = described_class.new(account: adr.account, external_id: adr.external_id, flash: empty_flash)

      rendered_html = render_and_parse(page)
      expect(rendered_html.text).to include("Refines “#{adr_being_refined.title}”")
    end
  end
end
