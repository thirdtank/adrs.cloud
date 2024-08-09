require "tests/app_test"

describe Actions::GitHubAuth do
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
          refute result.can_call?
          found_error = false
          result.each_violation do |object,field,key,context|
            if key == :no_account
              found_error = true
            end
          end
          assert found_error
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
          assert result.can_call?
          assert_equal result[:account],account
        end
      end
    end
    describe "invalid payload" do
      it "raises on wrong provider" do
        assert_raises do
          Actions::GitHubAuth.new.check({ "provider" => "twitter" })
        end
      end
      it "raises on missing uid" do
        assert_raises do
          Actions::GitHubAuth.new.check({ "provider" => "github", "info" => { "email" => "a@a.com" } })
        end
      end
      it "raises on missing email" do
        assert_raises do
          Actions::GitHubAuth.new.check({ "provider" => "github", "uid" => 99 })
        end
      end
    end
  end

end
