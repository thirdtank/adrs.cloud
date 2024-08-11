require "front_end/forms/app_form"

RSpec.describe Forms::Adrs::Tags do
  it "is new by default" do
    form = Forms::Adrs::Tags.new
    expect(form.new?).to eq(true)
  end
end
