require "spec_helper"

RSpec.describe EditDraftAdrByExternalIdPage do
  context "error message" do
    it "shows the error message" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, account: authenticated_account.account)
      request_context[:flash].alert = :adr_cannot_be_accepted

      page = described_class.new(authenticated_account:,
                                 external_id: adr.external_id)

      rendered_html = generate_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      alert = html_locator.element!("[role='alert']")
      expect(alert.text.to_s.strip).to include(t("adr_cannot_be_accepted"))
    end
  end
  context "form with errors" do
    it "shows the errors" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, :accepted, accepted_at: nil, account: authenticated_account.account)
      form                  = EditDraftAdrWithExternalIdForm.new(params: { external_id: adr.external_id, title: "aa" })

      page = described_class.new(authenticated_account:, external_id: adr.external_id, form: form)

      rendered_html = generate_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)
      expect(html_locator.element!("input[name=title][data-invalid]")).not_to eq(nil)
    end
  end
  context "replacing an ADR" do
    it "shows the ADR proposing to be replaced" do
      authenticated_account = create(:authenticated_account)
      adr                   = create(:adr, :accepted, accepted_at: nil, account: authenticated_account.account)
      adr_to_replace        = create(:adr, :accepted,                   account: authenticated_account.account)

      DB::ProposedAdrReplacement.create(
        replacing_adr_id: adr.id,
        replaced_adr_id: adr_to_replace.id,
      )

      page = described_class.new(authenticated_account:, external_id: adr.external_id)

      rendered_html = generate_and_parse(page)
      expect(rendered_html.text).to include(t("pages.EditDraftAdrByExternalIdPage.proposed_replacement", block: adr_to_replace.title))
    end
  end
  context "refining an ADR" do
    it "shows the ADR being refined" do
      authenticated_account = create(:authenticated_account)
      adr_being_refined     = create(:adr, :accepted, account: authenticated_account.account)
      adr                   = create(:adr,            account: authenticated_account.account,
                                                      refines_adr_id: adr_being_refined.id)

      page = described_class.new(authenticated_account:, external_id: adr.external_id)

      rendered_html = generate_and_parse(page)
      expect(rendered_html.text).to include(t("pages.EditDraftAdrByExternalIdPage.refines", block: adr_being_refined.title))
    end
  end
end
