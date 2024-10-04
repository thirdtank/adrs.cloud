require "spec_helper"

RSpec.describe NewDraftAdrPage do
  context "account has exceeded its limits" do
    it "redirects to the ADRs page" do
      account = create(:account)
      account.entitlement.update(max_non_rejected_adrs: 3)
      create(:adr, account: account)
      create(:adr, account: account)
      create(:adr, account: account)

      form = NewDraftAdrForm.new
      flash = empty_flash

      page = described_class.new(form:, authenticated_account: AuthenticatedAccount.new(account:), flash:)

      result = render_and_parse(page)
      expect(result.kind_of?(URI)).to eq(true)
      expect(result).to be_routing_for(AdrsPage)
      expect(flash.alert).to eq(:add_new_limit_exceeded)
    end
  end
  context "form is invalid" do
    it "shows the error message" do
      account = create(:account)
      form = NewDraftAdrForm.new(params: { title: "AAA" })
      form.server_side_constraint_violation(input_name: "title", key: :required)
      flash = request_context[:flash]

      page = described_class.new(form:, authenticated_account: AuthenticatedAccount.new(account:), flash: flash)

      rendered_html = render_and_parse(page)
      html_locator = Support::HtmlLocator.new(rendered_html)

      element = html_locator.element!("[role='alert']")
      expect(element.text.to_s.strip).to eq("ADR cannot be created. See below.")
    end
  end
  context "form is valid but blank" do
    it "does not show the error message" do
      account = create(:account)
      form = NewDraftAdrForm.new

      page = described_class.new(form:, authenticated_account: AuthenticatedAccount.new(account:), flash: empty_flash)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("[role='alert']").size).to eq(0)
    end
  end
  context "refining another ADR" do
    it "shows that ADR's title" do
      adr_being_refined = create(:adr, :accepted)
      account = adr_being_refined.account
      form = NewDraftAdrForm.new(params: { refines_adr_external_id: adr_being_refined.external_id })

      page = described_class.new(form:, authenticated_account: AuthenticatedAccount.new(account:), flash: empty_flash)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("[role='alert']").size).to eq(0)
      expect(rendered_html.text).to include(escape_html(adr_being_refined.title))
    end
  end
  context "proposing to replace another ADR" do
    it "shows that ADR's title" do
      adr_being_replaced = create(:adr, :accepted)
      account = adr_being_replaced.account
      form = NewDraftAdrForm.new(params: { replaced_adr_external_id: adr_being_replaced.external_id })

      page = described_class.new(form:, authenticated_account: AuthenticatedAccount.new(account:), flash: empty_flash)

      rendered_html = render_and_parse(page)
      expect(rendered_html.css("[role='alert']").size).to eq(0)
      expect(rendered_html.text).to include(escape_html(adr_being_replaced.title))
    end
  end

end
