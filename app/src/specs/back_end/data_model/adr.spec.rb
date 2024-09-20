require "spec_helper"

RSpec.describe DB::Adr do

  describe "::create" do
    it "returns a new instance using the generated ID" do
      account = create(:account)
      adr = described_class.create(title: "This is a test",account_id: account.id, created_at: Time.now)
      expect(adr.id).not_to eq(nil)
    end
  end

  describe "#tags" do
    context "adr is shared" do
      it "includes 'shared' in the tags" do
        adr = create(:adr, shareable_id: "asdfasdfasdf")
        expect(adr.tags).to include("shared")
      end
      it "omits 'shared' in the tags if asked" do
        adr = create(:adr, shareable_id: "asdfasdfasdf")
        expect(adr.tags(phony_shared:false)).not_to include("shared")
      end
    end
    context "adr is not shared" do
      it "does not include 'shared' in the tags" do
        adr = create(:adr, shareable_id: nil, tags: [ "foo" ])
        expect(adr.tags).not_to include("shared")
      end
    end
  end
  describe "#tags=" do
    it "removes 'shared' before saving" do
      adr = create(:adr, shareable_id: nil, tags: [ "foo" ])
      adr.tags = [ "foo", "bar", "SHARED" ]
      adr.save
      adr.reload
      expect(adr.tags).not_to include("shared")
    end
  end

end
