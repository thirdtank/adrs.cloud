require "spec_helper"
require "back_end/data_models/adr"

RSpec.describe DataModel::Adr do

  describe "::create" do
    it "returns a new instance using the generated ID" do
      account = create(:account)
      adr = described_class.create(title: "This is a test",account_id: account.id, created_at: Time.now)
      expect(adr.id).not_to eq(nil)
    end
  end

  describe "#tags" do
    context "adr is public" do
      it "includes 'public' in the tags" do
        adr = create(:adr, public_id: "asdfasdfasdf")
        expect(adr.tags).to include("public")
      end
    end
    context "adr is not public" do
      it "does not include 'public' in the tags" do
        adr = create(:adr, public_id: nil, tags: [ "foo" ])
        expect(adr.tags).not_to include("public")
      end
    end
  end
  describe "#tags=" do
    it "removes public before saving" do
      adr = create(:adr, public_id: nil, tags: [ "foo" ])
      adr.tags = [ "foo", "bar", "PUBLIC" ]
      adr.save
      adr.reload
      expect(adr.tags).not_to include("public")
    end
  end

end
