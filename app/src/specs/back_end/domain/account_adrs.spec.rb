require "spec_helper"
RSpec.describe AccountAdrs do
  describe "::search" do
    context "no tag provided" do
      it "returns all ADRs on the account" do
        account = create(:account)
        adrs = Set[
          create(:adr, account:),
          create(:adr, :rejected, account:),
          create(:adr, :rejected, account:),
          create(:adr, :accepted, account:),
          create(:adr, :accepted, account:),
        ]

        results = described_class.search(account:)

        expect(results.size).to eq(adrs.size)

        ids_found = results.adrs.map(&:id)
        aggregate_failures do
          adrs.each do |adr|
            expect(ids_found).to include(adr.id)
          end
        end
      end
    end
    context "tag provided" do
      context "the tag is the shared tag" do
        it "returns ADRs on the account that are shared" do
          account = create(:account)
          shared1 = create(:adr, :shared,  :accepted, account:)
          shared2 = create(:adr, :shared,  :accepted, account:)

          create(:adr, account:)
          create(:adr, :rejected, account:)
          create(:adr, :rejected, account:)
          create(:adr, :private, :accepted, account:)

          results = described_class.search(account:, tag: DataModel::Adr.phony_tag_for_shared)

          expect(results.size).to eq(2)

          ids_found = results.adrs.map(&:id)
          expect(ids_found).to include(shared1.id)
          expect(ids_found).to include(shared2.id)
        end
      end
      context "the tag is a normal tag" do
        it "returns ADRs on the account with that tag" do
          account = create(:account)
          tag     = "test tag"
          tagged1 = create(:adr, account:, tags: [ tag, "foo", "bar" ])
          tagged2 = create(:adr, account:, tags: [ "blah", tag ])

          create(:adr, account:)
          create(:adr, :rejected, account:)
          create(:adr, :rejected, account:)
          create(:adr, :private, :accepted, account:)

          results = described_class.search(account:, tag: tag)

          expect(results.size).to eq(2)

          ids_found = results.adrs.map(&:id)
          expect(ids_found).to include(tagged1.id)
          expect(ids_found).to include(tagged2.id)
        end
      end
    end
  end

  describe "::num_non_rejected" do
    it "counts the non-rejected ADRs on the account" do
      account = create(:account)

      create(:adr, account:)
      create(:adr, :rejected, account:)
      create(:adr, :rejected, account:)
      create(:adr, :accepted, account:)
      create(:adr, :accepted, account:)

      count = described_class.num_non_rejected(account:)

      expect(count).to eq(3)
    end
  end
end
