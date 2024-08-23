require "spec_helper"

RSpec.describe Actions::Adrs::Search do

  subject(:search_by_tag) { described_class.new }

  describe "#by_tag" do
    it "returns all adrs matching the tag" do
      tag_to_search_for = "test-tag"

      account       = create(:account)
      other_account = create(:account)

      has_tag               = create(:adr, account: account, tags: [ "foo", "bar", tag_to_search_for ])
      also_has_tag          = create(:adr, account: account, tags: [ tag_to_search_for, "crud" ])
      no_tag                = create(:adr, account: account, tags: [ "not-test-tag", "crud" ])
      has_tag_other_account = create(:adr, account: other_account, tags: [ tag_to_search_for, "crud" ])

      adrs = search_by_tag.by_tag(account: account, tag: "test-tag")
      expect(adrs.length).to eq(2)
      expect(adrs).to include(has_tag)
      expect(adrs).to include(also_has_tag)
    end
  end
end
