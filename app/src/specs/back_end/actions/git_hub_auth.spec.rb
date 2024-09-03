require "spec_helper"
require "back_end/actions/app_action"

RSpec.describe Actions::GitHubAuth do
  describe "#auth" do
    describe "valid payload" do
      describe "email is not in database" do
        it "returns nil" do
          hash = {
            "provider" => "github",
            "uid" => 99,
            "info" => {
              "email" => "non-existent@example.com",
            }
          }
          result = Actions::GitHubAuth.new.auth(hash)
          expect(result).to eq(nil)
        end
      end
      describe "email is in the database" do
        it "returns the account" do
          account = DataModel::Account.create(email: "gh-existent@example.com", created_at: Time.now)
          hash = {
            "provider" => "github",
            "uid" => 99,
            "info" => {
              "email" => account.email
            }
          }
          result = Actions::GitHubAuth.new.auth(hash)
          expect(result).to eq(account)
        end
      end
    end
    describe "invalid payload" do
      it "raises on wrong provider" do
        expect {
          Actions::GitHubAuth.new.auth({ "provider" => "twitter" })
        }.to raise_error(/asked to process/)
      end
      it "raises on missing uid" do
        expect {
          Actions::GitHubAuth.new.auth({ "provider" => "github", "info" => { "email" => "a@a.com" } })
        }.to raise_error(/did not get a uid/)
      end
      it "raises on missing email" do
        expect {
          Actions::GitHubAuth.new.auth({ "provider" => "github", "uid" => 99 })
        }.to raise_error(/did not get an email/)
      end
    end
  end

end
