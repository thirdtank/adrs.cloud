require "spec_helper"
RSpec.describe Admin::AccountsByExternalIdPage do
  context "authenticated_account has admin privileges" do
    it "404s" do
      authenticated_account = create(:authenticated_account)
      account = create(:account)

      result = render(described_class.new(external_id: account.external_id, flash: empty_flash, authenticated_account:))
      expect(result).to have_returned_http_status(404)
    end
  end
  context "authenticated_account has admin privileges" do
    it "shows the actual values from their entitlement" do
      authenticated_account = create(:authenticated_account, :admin)
      account = create(:account)
      account.entitlement.update(max_non_rejected_adrs: nil)

      rendered_html = render_and_parse(described_class.new(external_id: account.external_id, flash: empty_flash, authenticated_account:))
      html_locator = Support::HtmlLocator.new(rendered_html)

      label = html_locator.element!("table tr label[for='max_non_rejected_adrs']")
      expect(label).not_to eq(nil)

      row = label.parent.parent
      row_locator = Support::HtmlLocator.new(row)

      input = row_locator.element!("input[name='max_non_rejected_adrs']")
      expect(input.attribute("value")).to eq(nil)

      effective = row_locator.element!("adr-entitlement-effective")
      expect(effective.text.strip).to eq(account.entitlement.entitlement_default.max_non_rejected_adrs.to_s)
    end
    it "shows that the default values apply when their entitlement's values are blank" do
      authenticated_account = create(:authenticated_account, :admin)
      account = create(:account)
      max_non_rejected_adrs = account.entitlement.entitlement_default.max_non_rejected_adrs + 1
      account.entitlement.update(max_non_rejected_adrs: max_non_rejected_adrs)

      rendered_html = render_and_parse(described_class.new(external_id: account.external_id, flash: empty_flash, authenticated_account:))
      html_locator = Support::HtmlLocator.new(rendered_html)

      label = html_locator.element!("table tr label[for='max_non_rejected_adrs']")
      expect(label).not_to eq(nil)

      row = label.parent.parent
      row_locator = Support::HtmlLocator.new(row)

      input = row_locator.element!("input[name='max_non_rejected_adrs']")
      expect(input.attribute("value").value).to eq(max_non_rejected_adrs.to_s)

      effective = row_locator.element!("adr-entitlement-effective")
      expect(effective.text.strip).to eq(max_non_rejected_adrs.to_s)
    end
  end
end
