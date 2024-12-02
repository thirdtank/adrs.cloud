require "spec_helper"
RSpec.describe Admin::HomePage do
  describe "authenticated_account is entitled to this page" do
    it "renders the page" do
      authenticated_account = create(:authenticated_account, :admin)
      result = described_class.new(flash: empty_flash, authenticated_account:).handle!
      expect(result).not_to have_returned_http_status
    end
  end
  describe "authenticated_account is not entitled to this page" do
    it "returns a 404" do
      authenticated_account = create(:authenticated_account)
      result = described_class.new(flash: empty_flash, authenticated_account:).handle!
      expect(result).to have_returned_http_status(404)
    end
  end
end
