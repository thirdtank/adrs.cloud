require "spec_helper"
require "front_end/forms/app_form"

RSpec.describe NewDraftAdrForm do
  it "is new by default" do
    form = described_class.new
    expect(form.new?).to eq(true)
  end
  it "is new if refines_adr_external_id is present" do
    form = described_class.new(params: { refines_adr_external_id: "foo" } )
    expect(form.new?).to eq(true)
  end
  it "is new if replaced_adr_external_id is present" do
    form = described_class.new(params: { replaced_adr_external_id: "foo" } )
    expect(form.new?).to eq(true)
  end
end
