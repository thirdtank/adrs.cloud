require "spec_helper"
require "back_end/actions/app_action"

RSpec.describe Actions::DevOnlyAuth do
  describe "#auth" do
    describe "email is not in the database" do
      it "returns nil" do
        result = Actions::DevOnlyAuth.new.auth("non-existent@example.com")
        expect(result).to eq(nil)
      end
    end
    describe "email is in the database" do
      it "returns the account" do
        account = DataModel::Account.create(email: "existent@example.com", created_at: Time.now)
        result = Actions::DevOnlyAuth.new.auth(account.email)
        expect(result).to eq(account)
      end
    end
  end

end
