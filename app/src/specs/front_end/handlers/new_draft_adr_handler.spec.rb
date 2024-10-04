require "spec_helper"

RSpec.describe NewDraftAdrHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "limit on adrs exceeded" do
      it "returns a 403 as this should never have been posted to" do
        authenticated_account = create(:authenticated_account)

        authenticated_account.account.entitlement.update(max_non_rejected_adrs: 3)

        3.times do
          create(:adr, account: authenticated_account.account)
        end

        form = NewDraftAdrForm.new
        result = handler.handle!(form:,authenticated_account:,flash: empty_flash)
        expect(result.to_i).to eq(403)
      end
    end
    context "there are constraint violations" do
      it "has violations on the form, an error message in the flash, and re-renders the page" do
        authenticated_account = create(:authenticated_account)
        form = NewDraftAdrForm.new(params: { title: "aaaaaaaaa"})

        flash = empty_flash
        result = handler.handle!(form: , authenticated_account:, flash:)

        expect(form.constraint_violations?).to eq(true)
        expect(form).to have_constraint_violation(:title, key: :not_enough_words)
        expect(flash.alert).to eq(:adr_invalid)
        expect(result.class).to eq(NewDraftAdrPage)
        expect(result.form).to eq(form)
      end
    end
    context "there are no constraint violations" do
      it "saves and redirects to the edit page" do
        authenticated_account = create(:authenticated_account)
        form = NewDraftAdrForm.new(params: { title: "This is a test"})
        flash = empty_flash

        result = handler.handle!(form:,authenticated_account:,flash:)

        adr = DB::Adr.last

        expect(result).to be_routing_for(EditDraftAdrByExternalIdPage,external_id:adr.external_id)
        expect(flash[:notice]).to eq(:adr_created)
      end
      context "there is a refines_adr_external_id" do
        context "this account cannot access it" do
          it "sets refines_adr_id to nil" do
            authenticated_account = create(:authenticated_account)
            adr_being_refined = create(:adr, :accepted)
            form = NewDraftAdrForm.new(params: { title: "This is a test", refines_adr_external_id: adr_being_refined.external_id})
            flash = empty_flash

            result = handler.handle!(form:,authenticated_account:,flash:)

            adr = DB::Adr.last
            expect(adr.title).to eq("This is a test")
            expect(adr.refines_adr).to eq(nil)
            expect(result).to be_routing_for(EditDraftAdrByExternalIdPage,external_id:adr.external_id)
            expect(flash[:notice]).to eq(:adr_created)
          end
        end
        context "this account can access it" do
          it "saves it to the adr" do
            authenticated_account = create(:authenticated_account)
            adr_being_refined = create(:adr, :accepted, account: authenticated_account.account)
            form = NewDraftAdrForm.new(params: { title: "This is a test", refines_adr_external_id: adr_being_refined.external_id})
            flash = empty_flash

            result = handler.handle!(form:,authenticated_account:,flash:)

            adr = DB::Adr.last
            expect(adr.title).to eq("This is a test")
            expect(adr.refines_adr).to eq(adr_being_refined)
            expect(result).to be_routing_for(EditDraftAdrByExternalIdPage,external_id:adr.external_id)
            expect(flash[:notice]).to eq(:adr_created)
          end
        end
      end
      context "there is a replaced_adr_external_id" do
        it "creates a proposed_adr_replacement" do
          authenticated_account = create(:authenticated_account)
          adr_being_replaced = create(:adr, :accepted, account: authenticated_account.account)
          form = NewDraftAdrForm.new(params: { title: "This is a test", replaced_adr_external_id: adr_being_replaced.external_id})
          flash = empty_flash

          result = handler.handle!(form:,authenticated_account:,flash:)

          adr = DB::Adr.last
          expect(adr.title).to eq("This is a test")
          expect(adr.proposed_to_replace_adr).to eq(adr_being_replaced)
          expect(result).to be_routing_for(EditDraftAdrByExternalIdPage,external_id:adr.external_id)
          expect(flash[:notice]).to eq(:adr_created)
        end
      end
    end
  end
end
