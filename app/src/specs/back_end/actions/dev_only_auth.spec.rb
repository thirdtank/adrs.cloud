require "spec_helper"
require "back_end/actions/app_action"

RSpec.describe Actions::DevOnlyAuth do
  describe "#check" do
    describe "email is not in the database" do
      it "returns an error" do
        result = Actions::DevOnlyAuth.new.check("non-existent@example.com")
        expect(result.can_call?).to eq(false)
        found_error = false
        result.each_violation do |object,field,key,context|
          if field == :email
            if key == :no_account
              found_error = true
            end
          end
        end
        expect(found_error).to eq(true)
      end
    end
    describe "email is in the database" do
      it "returns the account" do
        account = DataModel::Account.create(email: "existent@example.com", created_at: Time.now)
        result = Actions::DevOnlyAuth.new.check(account.email)
        expect(result.can_call?).to eq(true)
        expect(result[:account]).to eq(account)
      end
    end
  end

end
