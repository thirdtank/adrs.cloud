require "tests/app_test"
require "front_end/forms/app_form"

describe Forms::Adrs::Tags do
  it "is new by default" do
    form = Forms::Adrs::Tags.new
    assert form.new?
  end

end
