require "spec_helper"
require "back_end/actions/app_action"

RSpec.describe Actions::GitHubAuth do
  describe "#check" do
    describe "valid payload" do
      describe "email is not in database" do
        it "returns an error" do
          hash = {
            "provider" => "github",
            "uid" => 99,
            "info" => {
              "email" => "non-existent@example.com",
            }
          }
          result = Actions::GitHubAuth.new.check(hash)
          expect(result.can_call?).to eq(false)
          found_error = false
          result.each_violation do |object,field,key,context|
            if key == :no_account
              found_error = true
            end
          end
          expect(found_error).to eq(true)
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
          result = Actions::GitHubAuth.new.check(hash)
          expect(result.can_call?).to eq(true)
          expect(result[:account]).to eq(account)
        end
      end
    end
    describe "invalid payload" do
      it "raises on wrong provider" do
        expect {
          Actions::GitHubAuth.new.check({ "provider" => "twitter" })
        }.to raise_error
      end
      it "raises on missing uid" do
        expect {
          Actions::GitHubAuth.new.check({ "provider" => "github", "info" => { "email" => "a@a.com" } })
        }.to raise_error
      end
      it "raises on missing email" do
        expect {
          Actions::GitHubAuth.new.check({ "provider" => "github", "uid" => 99 })
        }.to raise_error
      end
    end
  end

end
