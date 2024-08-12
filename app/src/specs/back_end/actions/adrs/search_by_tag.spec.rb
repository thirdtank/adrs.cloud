require "spec_helper"

RSpec.describe Actions::Adrs::SearchByTag do

  subject(:search_by_tag) { described_class.new }

  describe "#call" do
    it "returns all adrs matching the tag" do
      account       = DataModel::Account.create(email: "pat@example.com", created_at: Time.now)
      other_account = DataModel::Account.create(email: "chris@example.com", created_at: Time.now)

      has_tag = DataModel::Adr.create(account_id: account.id,
                                      title: "This has the tag",
                                      tags: [ "foo", "bar", "test-tag" ],
                                      created_at: Time.now)
      also_has_tag = DataModel::Adr.create(account_id: account.id,
                                           title: "This also has the tag",
                                           tags: [ "test-tag", "crud" ],
                                           created_at: Time.now)
      does_not_have_tag = DataModel::Adr.create(account_id: account.id,
                                                title: "This does not have the tag",
                                                tags: [ "not-test-tag", "crud" ],
                                                created_at: Time.now)
      has_tag_other_account = DataModel::Adr.create(account_id: other_account.id,
                                                    title: "This has the tag",
                                                    tags: [ "test-tag", "crud" ],
                                                    created_at: Time.now)

      adrs = search_by_tag.call(account: account, tag: "test-tag")
      expect(adrs.length).to eq(2)
      expect(adrs).to include(has_tag)
      expect(adrs).to include(also_has_tag)
    end
  end
end
