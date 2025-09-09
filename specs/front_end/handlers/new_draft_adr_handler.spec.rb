require "spec_helper"

RSpec.describe NewDraftAdrHandler do
  describe "#handle!" do
    context "limit on adrs exceeded" do
      it "returns a 403 as this should never have been posted to" do
        authenticated_account = create(:authenticated_account)
        authenticated_account.account.entitlement.update(max_non_rejected_adrs: 3)

        3.times do
          create(:adr, account: authenticated_account.account)
        end

        form = NewDraftAdrForm.new
        flash = empty_flash
        handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

        result = handler.handle!
        expect(result.to_i).to eq(403)
      end
    end
    context "there are constraint violations" do
      context "client-side only" do
        it "has violations on the form, an error message in the flash, and re-renders the page" do
          authenticated_account = create(:authenticated_account)
          form = NewDraftAdrForm.new(params: { title: ""})
          flash = empty_flash
          handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

          result = handler.handle!

          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:title, key: :valueMissing)
          expect(flash.alert).to eq("new_adr_invalid")
          expect(result.class).to eq(NewDraftAdrPage)
          expect(result.form).to eq(form)
        end
      end
      context "server-side only" do
        it "has violations on the form, an error message in the flash, and re-renders the page" do
          authenticated_account = create(:authenticated_account)
          form = NewDraftAdrForm.new(params: { title: "aaaaaaaaa", project_external_id: SecureRandom.uuid })
          flash = empty_flash
          handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

          result = handler.handle!

          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:title, key: :not_enough_words)
          expect(flash.alert).to eq("new_adr_invalid")
          expect(result.class).to eq(NewDraftAdrPage)
          expect(result.form).to eq(form)
        end
      end
    end
    context "there are no constraint violations" do
      it "saves and redirects to the edit page" do
        authenticated_account = create(:authenticated_account)
        form = NewDraftAdrForm.new(params: {
          title: "This is a test",
          project_external_id: authenticated_account.account.projects.first.external_id
        })
        flash = empty_flash
        handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

        result = handler.handle!

        adr = DB::Adr.last

        expect(result).to be_routing_for(EditDraftAdrByExternalIdPage, external_id: adr.external_id)
        expect(flash[:notice]).to eq("adr_created")
      end
      context "there is a refines_adr_external_id" do
        context "this account cannot access it" do
          it "sets refines_adr_id to nil" do
            authenticated_account = create(:authenticated_account)
            adr_being_refined = create(:adr, :accepted)
            form = NewDraftAdrForm.new(params: {
              title: "This is a test",
              refines_adr_external_id: adr_being_refined.external_id,
              project_external_id: authenticated_account.account.projects.first.external_id
            })
            flash = empty_flash
            handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

            result = handler.handle!

            adr = DB::Adr.last
            expect(adr.title).to eq("This is a test")
            expect(adr.refines_adr).to eq(nil)
            expect(result).to be_routing_for(EditDraftAdrByExternalIdPage, external_id: adr.external_id)
            expect(flash[:notice]).to eq("adr_created")
          end
        end
        context "this account can access it" do
          it "saves it to the adr" do
            authenticated_account = create(:authenticated_account)
            adr_being_refined = create(:adr, :accepted, account: authenticated_account.account, project: authenticated_account.account.projects.first)
            form = NewDraftAdrForm.new(params: {
              title: "This is a test",
              refines_adr_external_id: adr_being_refined.external_id,
              project_external_id: authenticated_account.account.projects.first.external_id
            })
            flash = empty_flash
            handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

            result = handler.handle!

            adr = DB::Adr.last
            expect(adr.title).to eq("This is a test")
            expect(adr.refines_adr).to eq(adr_being_refined)
            expect(result).to be_routing_for(EditDraftAdrByExternalIdPage, external_id: adr.external_id)
            expect(flash[:notice]).to eq("adr_created")
          end
        end
      end
      context "there is a replaced_adr_external_id" do
        it "creates a proposed_adr_replacement" do
          authenticated_account = create(:authenticated_account)
          adr_being_replaced = create(:adr, :accepted, account: authenticated_account.account, project: authenticated_account.account.projects.first)
          form = NewDraftAdrForm.new(params: {
            title: "This is a test",
            replaced_adr_external_id: adr_being_replaced.external_id,
            project_external_id: authenticated_account.account.projects.first.external_id
          })
          flash = empty_flash
          handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

          result = handler.handle!

          adr = DB::Adr.last
          expect(adr.title).to eq("This is a test")
          expect(adr.proposed_to_replace_adr).to eq(adr_being_replaced)
          expect(result).to be_routing_for(EditDraftAdrByExternalIdPage, external_id: adr.external_id)
          expect(flash[:notice]).to eq("adr_created")
        end
      end
    end
  end
end
