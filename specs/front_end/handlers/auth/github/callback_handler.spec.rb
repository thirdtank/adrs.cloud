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
        flash = empty_flash
        handler = described_class.new(env: env, flash: flash, session: session)

        result = handler.handle!

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
        handler = described_class.new(env: env, flash: flash, session: session)

        result = handler.handle!

        expect(result.class).to eq(HomePage)
        expect(flash.alert).to eq("auth.no_account")
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
      handler = described_class.new(env: env, flash: flash, session: session)

      result = handler.handle!
      expect(result.class).to eq(HomePage)
      expect(flash.alert).to eq("auth.no_account")
      expect(session.logged_in?).to eq(false)
    end
  end
  context "an internal error happens" do
    it "sets an error in the flash and redirects to the HomePage" do
      external_account = create(:external_account,provider: "github")
      flash = empty_flash
      session = empty_session
      env = {
        "omniauth.auth" => {
          "provider" => "github",
          "uid" => external_account.external_account_id,
          "info" => {
            "email" => "different" + external_account.account.email
          }
        }
      }
      handler = described_class.new(env: env, flash: flash, session: session)

      result = handler.handle!
      expect(result.class).to eq(HomePage)
      expect(flash.alert).to eq("domain.account.github.uid_used_by_other_account")
      expect(session.logged_in?).to eq(false)
    end
  end
end
