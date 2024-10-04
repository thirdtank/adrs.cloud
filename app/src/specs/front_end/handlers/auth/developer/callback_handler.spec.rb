require "spec_helper"
RSpec.describe Auth::Developer::CallbackHandler do
  context "email exists" do
    it "sets the id in the session and redirects to the AdrsPage" do
      account = create(:account)
      session = empty_session

      result = described_class.new.handle!(email: account.email,
                                           flash: empty_flash,
                                           session: session)
      expect(result).to be_routing_for(AdrsPage)
      expect(session.logged_in_account_id).to eq(account.external_id)
    end
  end
  context "email does not exist" do
    it "sets an error in the flash and redirects to the HomePage" do
      flash = empty_flash
      session = empty_session
      result = described_class.new.handle!(email: "nope@example.com",
                                           flash: flash,
                                           session: session)
      expect(result.class).to eq(HomePage)
      expect(flash.alert).to eq("auth.no_account")
      expect(session.logged_in?).to eq(false)
    end
  end
end
