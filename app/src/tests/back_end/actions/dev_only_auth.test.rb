require "tests/app_test"
require "back_end/actions/app_action"

describe Actions::DevOnlyAuth do
  describe "#check" do
    describe "email is not in the database" do
      it "returns an error" do
        result = Actions::DevOnlyAuth.new.check("non-existent@example.com")
        refute result.can_call?
        found_error = false
        result.each_violation do |object,field,key,context|
          if field == :email
            if key == :no_account
              found_error = true
            end
          end
        end
        assert found_error
      end
    end
    describe "email is in the database" do
      it "returns the account" do
        account = DataModel::Account.create(email: "existent@example.com", created_at: Time.now)
        result = Actions::DevOnlyAuth.new.check(account.email)
        assert result.can_call?
        assert_equal result[:account],account
      end
    end
  end

end
