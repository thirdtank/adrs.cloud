require "front_end/forms/app_form"

RSpec.describe Forms::Adrs::Draft do
  it "is new by default" do
    form = Forms::Adrs::Draft.new()
    expect(form.new?).to eq(true)
  end
  it "is new if refines_adr_external_id is present" do
    form = Forms::Adrs::Draft.new(refines_adr_external_id: "foo")
    expect(form.new?).to eq(true)
  end
  it "is new if replaced_adr_external_id is present" do
    form = Forms::Adrs::Draft.new(replaced_adr_external_id: "foo")
    expect(form.new?).to eq(true)
  end
  it "is not new if external_id is present" do
    form = Forms::Adrs::Draft.new(external_id: "foo")
    expect(form.new?).to eq(false)
  end

end
