require "spec_helper"
RSpec.describe AcceptedAdr do
  describe "::find" do
    it "returns nil if the ADR cannot be found" do
      adr = create(:adr, :accepted)
      account = create(:account)

      accepted_adr = AcceptedAdr.find(external_id: adr.external_id,account:)

      expect(accepted_adr).to eq(nil)
    end
    it "returns nil if the ADR exists on the account, but is not accepted" do
      adr = create(:adr)
      account = adr.account

      accepted_adr = AcceptedAdr.find(external_id: adr.external_id,account:)

      expect(accepted_adr).to eq(nil)
    end
    it "returns an AcceptedAdr if the ADR can be found" do
      adr = create(:adr, :accepted)
      account = adr.account

      accepted_adr = AcceptedAdr.find(external_id: adr.external_id,account:)

      expect(accepted_adr).not_to         eq(nil)
      expect(accepted_adr.external_id).to eq(adr.external_id)
    end
  end
  describe "::find!" do
    it "raises an error if the ADR cannot be found" do
      adr = create(:adr, :accepted)
      account = create(:account)

      expect {
        AcceptedAdr.find!(external_id: adr.external_id,account:)
      }.to raise_error(Brut::Framework::Errors::NotFound)
    end
    it "raises an error if the ADR exists on the account, but is not accepted" do
      adr = create(:adr)
      account = adr.account

      expect {
        AcceptedAdr.find!(external_id: adr.external_id,account:)
      }.to raise_error(Brut::Framework::Errors::NotFound)
    end
    it "returns an AcceptedAdr if the ADR can be found" do
      adr = create(:adr, :accepted)
      account = adr.account

      accepted_adr = AcceptedAdr.find!(external_id: adr.external_id,account:)

      expect(accepted_adr).not_to         eq(nil)
      expect(accepted_adr.external_id).to eq(adr.external_id)
    end
  end
  describe "#update_tags" do
    it "updates the tags based on the stringified version of the tags" do
      adr = create(:adr, :accepted)

      accepted_adr = AcceptedAdr.find!(external_id: adr.external_id,account: adr.account)

      accepted_adr.update_tags(form: AdrTagsWithExternalIdForm.new(params: { tags: "foo, bar, blah" }))

      adr.reload
      expect(adr.tags).to eq([ "foo", "bar", "blah" ])
    end
  end
  describe "#stop_sharing!" do
    it "clears the shareable_id" do
      adr = create(:adr, :shared)

      accepted_adr = AcceptedAdr.find!(external_id: adr.external_id,account: adr.account)

      accepted_adr.stop_sharing!

      adr.reload
      expect(adr.shareable_id).to eq(nil)
    end
  end
  describe "#share!" do
    context "has no shareable_id" do
      it "sets a shareable_id" do
        adr = create(:adr, :private)

        accepted_adr = AcceptedAdr.find!(external_id: adr.external_id,account: adr.account)

        accepted_adr.share!

        adr.reload
        expect(adr.shareable_id).not_to eq(nil)
      end
    end
    context "has a shareable_id" do
      it "sets a new shareable_id" do
        adr = create(:adr, :shared)
        existing_id = adr.shareable_id

        accepted_adr = AcceptedAdr.find!(external_id: adr.external_id,account: adr.account)

        accepted_adr.share!

        adr.reload
        expect(adr.shareable_id).not_to eq(nil)
        expect(adr.shareable_id).not_to eq(existing_id)
      end
    end
  end
  describe "#propose_replacement" do
    context "both ADRs have the same account" do
      context "both ADRs have the same project" do
        it "creates a ProposedAdrReplacement" do
          account                  = create(:account)
          adr_being_replaced       = create(:adr, :accepted, account:, project: account.projects.first)
          proposed_replacement_adr = create(:adr, account:, project: account.projects.first)

          accepted_adr = AcceptedAdr.find!(
            external_id: adr_being_replaced.external_id,
            account:
          )

          expect {
            accepted_adr.propose_replacement(proposed_replacement_adr)
          }.to change {
            DB::ProposedAdrReplacement.count
          }.by(1)

          adr_being_replaced.reload
          proposed_replacement_adr.reload
          expect(proposed_replacement_adr.proposed_to_replace_adr).to eq(adr_being_replaced)
        end
        it "requires that the new ADR not be accepted" do
          account                  = create(:account)
          adr_being_replaced       = create(:adr, :accepted, account:, project: account.projects.first)
          proposed_replacement_adr = create(:adr, :accepted, account:, project: account.projects.first)

          accepted_adr = AcceptedAdr.find!(
            external_id: adr_being_replaced.external_id,
            account:
          )

          expect {
            accepted_adr.propose_replacement(proposed_replacement_adr)
          }.to be_a_bug
        end
      end
      context "ADRs have different projects" do
        it "raises an error" do
          account                  = create(:account)
          project                  = account.projects.first
          other_project            = create(:project, account: account)
          adr_being_replaced       = create(:adr, :accepted, account:, project: project)
          proposed_replacement_adr = create(:adr, account:, project: other_project)

          accepted_adr = AcceptedAdr.find!(
            external_id: adr_being_replaced.external_id,
            account:
          )

          expect {
            accepted_adr.propose_replacement(proposed_replacement_adr)
          }.to be_a_bug

        end
      end
    end
    context "both ADRs have different accounts" do
      it "raises an error" do
        adr_being_replaced       = create(:adr, :accepted)
        proposed_replacement_adr = create(:adr)

        accepted_adr = AcceptedAdr.find!(
          external_id: adr_being_replaced.external_id,
          account: adr_being_replaced.account,
        )

        expect {
          accepted_adr.propose_replacement(proposed_replacement_adr)
        }.to be_a_bug
      end
    end
  end
end
