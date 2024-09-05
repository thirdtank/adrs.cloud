require "spec_helper"
RSpec.describe Auth::Github::CallbackHandler do
  context "email exists" do
    it "sets the id in the session and redirects to the AdrsPage" do
      account = create(:account)
      session = empty_session
      env = {
        "omniauth.auth" => {
          "provider" => "github",
          "uid" => SecureRandom.uuid,
          "info" => {
            "email" => account.email
          }
        }
      }

      result = described_class.new.handle!(env: env,
                                           flash: empty_flash,
                                           session: session)
      expect(result).to be_routing_for(AdrsPage)
      expect(session["user_id"]).to eq(account.external_id)
    end
  end
  context "email does not exist" do
    it "sets an error in the flash and redirects to the HomePage" do
      flash = empty_flash
      session = empty_session
      env = {
        "omniauth.auth" => {
          "provider" => "github",
          "uid" => SecureRandom.uuid,
          "info" => {
            "email" => "nope@example.com",
          }
        }
      }
      result = described_class.new.handle!(env: env,
                                           flash: flash,
                                           session: session)
      expect(result.class).to eq(HomePage)
      expect(flash[:error]).to eq("auth.no_account")
      expect(session.key?("user_id")).to eq(false)
    end
  end
end
