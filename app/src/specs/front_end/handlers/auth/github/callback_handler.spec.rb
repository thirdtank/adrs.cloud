require "spec_helper"
RSpec.describe Auth::Github::CallbackHandler do
  context "email exists" do
    context "account is active" do
      it "sets the id in the session and redirects to the AdrsPage" do
        account = create(:account, :active)
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
        result = described_class.new.handle!(env:, flash: empty_flash, session:)

        expect(result).to be_routing_for(AdrsPage)
        expect(session.logged_in_account_id).to eq(account.external_id)
      end
    end
    context "account is deactivated" do
      it "sets the id in the session and redirects to the AdrsPage" do
        account = create(:account, :deactivated)
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

        flash = empty_flash

        result = described_class.new.handle!(env:, flash:, session:)

        expect(result.class).to eq(HomePage)
        expect(flash[:error]).to eq("auth.no_account")
        expect(session.logged_in?).to eq(false)
      end
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
      expect(session.logged_in?).to eq(false)
    end
  end
end
