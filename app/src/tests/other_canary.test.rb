require "tests/app_test"
require "back_end/data_models/app_data_model"

describe "other canary" do
  it "should run tests" do
    assert true
  end
  it "can deal with the DB" do
    account = DataModel::Account.create(email: "pat@example.com", created_at: Time.now)
    refute account.id.nil?
  end
end
