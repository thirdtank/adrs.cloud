require "tests/app_test"
require "front_end/forms/app_form"

describe Forms::Adrs::Draft do
  it "is new by default" do
    form = Forms::Adrs::Draft.new()
    assert form.new?
  end
  it "is new if refines_adr_external_id is present" do
    form = Forms::Adrs::Draft.new(refines_adr_external_id: "foo")
    assert form.new?
  end
  it "is new if replaced_adr_external_id is present" do
    form = Forms::Adrs::Draft.new(replaced_adr_external_id: "foo")
    assert form.new?
  end
  it "is not new if external_id is present" do
    form = Forms::Adrs::Draft.new(external_id: "foo")
    refute form.new?
  end

end
