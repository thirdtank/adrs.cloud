require "spec_helper"
RSpec.describe Admin::AccountsPage do
  context "authenticated_account is not an admin" do
    it "should 404" do
      authenticated_account = create(:authenticated_account)

      page = described_class.new(search_string: "", authenticated_account:)

      result = render(page)
      expect(result).to have_returned_http_status(404)
    end
  end
  context "authenticated_account is an admin" do
    it "should show all users for an empty search string" do
      pat     = create(:account, email: "pat@example.com")
      chris   = create(:account, email: "chris@example.com")
      cameron = create(:account, email: "cameron@example.net")
      authenticated_account = create(:authenticated_account, :admin)

      page = described_class.new(search_string: "", authenticated_account:)

      rendered_html = render_and_parse(page)
      expect(rendered_html.text).to include(authenticated_account.account.email)
      expect(rendered_html.text).to include(pat.email)
      expect(rendered_html.text).to include(chris.email)
      expect(rendered_html.text).to include(cameron.email)
    end
    context "search string given" do
      it "should show results where emails contain the search string" do
        authenticated_account = create(:authenticated_account, :admin)
        pat     = create(:account, email: "pat@example.com")
        chris   = create(:account, email: "chris@example.com")
        cameron = create(:account, email: "cameron@example.net")

        page = described_class.new(search_string: "example.com", authenticated_account:)

        rendered_html = render_and_parse(page)
        expect(rendered_html.text).to     include(pat.email)
        expect(rendered_html.text).to     include(chris.email)
        expect(rendered_html.text).not_to include(cameron.email)
      end
      it "should show none matched if there are no matching accounts" do
        authenticated_account = create(:authenticated_account, :admin)
        create(:account)
        create(:account)
        page = described_class.new(search_string: "@gmail.com", authenticated_account:)

        rendered_html = render_and_parse(page)
        expect(rendered_html.text).to include("None Matched")
      end
    end
  end
end
