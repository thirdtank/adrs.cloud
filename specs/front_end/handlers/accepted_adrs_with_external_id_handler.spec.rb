require "spec_helper"
RSpec.describe AcceptedAdrsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        authenticated_account = create(:authenticated_account)
        form                  = AcceptedAdrsWithExternalIdForm.new
        expect {
          handler.handle!(form:,authenticated_account:,external_id: "foobar", flash:empty_flash)
        }.to raise_error(Sequel::NoMatchingRow)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          authenticated_account = create(:authenticated_account)
          adr                   = create(:adr)
          form                  = AcceptedAdrsWithExternalIdForm.new
          expect {
            handler.handle!(form:,authenticated_account:,external_id: adr.external_id, flash: empty_flash)
          }.to raise_error(Sequel::NoMatchingRow)
        end
      end
      context "account can access it" do
        context "there are constraint violations" do
          it "indicates errors on the form" do
            authenticated_account = create(:authenticated_account)
            adr                   = create(:adr, account: authenticated_account.account)
            form                  = AcceptedAdrsWithExternalIdForm.new(params: {
              title: adr.title,
              project_external_id: authenticated_account.account.projects.first.external_id,
            })
            flash                 = empty_flash

            result = handler.handle!(form:,authenticated_account:,flash:, external_id: adr.external_id)

            expect(result.class).to eq(EditDraftAdrByExternalIdPage)
            expect(result.form).to be(form)
            expect(flash.alert).to eq(:adr_cannot_be_accepted)
            expect(form.constraint_violations?).to eq(true)
            expect(form).to have_constraint_violation(:context   , key: :required)
            expect(form).to have_constraint_violation(:facing    , key: :required)
            expect(form).to have_constraint_violation(:decision  , key: :required)
            expect(form).to have_constraint_violation(:neglected , key: :required)
            expect(form).to have_constraint_violation(:achieve   , key: :required)
            expect(form).to have_constraint_violation(:accepting , key: :required)
            expect(form).to have_constraint_violation(:because   , key: :required)
          end
        end
        context "there are no constraint violations" do
          context "it is not accepted" do
            it "sets accepted_at" do
              authenticated_account = create(:authenticated_account)
              adr                   = create(:adr, :accepted, accepted_at: nil, account: authenticated_account.account, project: authenticated_account.account.projects.first)
              flash                 = empty_flash
              form                  = AcceptedAdrsWithExternalIdForm.new(params: adr.to_hash.slice(
                :title,
                :context,
                :facing,
                :decision,
                :neglected,
                :achieve,
                :accepting,
                :because,
                # omitting tags because it doesn't matter and requires transformation to a string
              ).merge(project_external_id: adr.project.external_id))

              result = handler.handle!(form:,authenticated_account:,flash:,external_id: adr.external_id)
              expect(result).to be_routing_for(AdrsByExternalIdPage,external_id: adr.external_id)
              expect(flash[:notice]).to eq(:adr_accepted)
              adr.reload

              expect(adr.accepted_at).to be_within(1_000).of(Time.now)
            end
          end
          context "it is already accepted" do
            it "raises not found" do
              authenticated_account = create(:authenticated_account)
              accepted_at           = Time.now - 10_000
              adr                   = create(:adr, :accepted, accepted_at: accepted_at, account: authenticated_account.account)
              flash                 = empty_flash
              form                  = AcceptedAdrsWithExternalIdForm.new(params: adr.to_hash.slice(
                :title,
                :context,
                :facing,
                :decision,
                :neglected,
                :achieve,
                :accepting,
                :because,
                # omitting tags because it doesn't matter and requires transformation to a string
              ))

              expect {
                handler.handle!(form:,authenticated_account:,flash:empty_flash, external_id: adr.external_id )
              }.to raise_error(Sequel::NoMatchingRow)
            end
          end
          context "it is intended to replace another ADR that is accepted" do
            it "sets that ADR as having been replaced by this one" do
              authenticated_account = create(:authenticated_account)
              adr                   = create(:adr, :accepted, accepted_at: nil, account: authenticated_account.account, project: authenticated_account.account.projects.first)
              adr_to_replace        = create(:adr, :accepted,                   account: authenticated_account.account, project: authenticated_account.account.projects.first)
              flash                 = empty_flash
              form                  = AcceptedAdrsWithExternalIdForm.new(params: adr.to_hash.slice(
                :title,
                :context,
                :facing,
                :decision,
                :neglected,
                :achieve,
                :accepting,
                :because,
                # omitting tags because it doesn't matter and requires transformation to a string
              ).merge({ project_external_id: adr.project.external_id }))
              DB::ProposedAdrReplacement.create(
                replacing_adr_id: adr.id,
                replaced_adr_id: adr_to_replace.id,
              )

              result = handler.handle!(form:,authenticated_account:,flash:,external_id: adr.external_id)
              expect(result).to be_routing_for(AdrsByExternalIdPage,external_id: adr.external_id)
              expect(flash[:notice]).to eq(:adr_accepted)

              adr.reload
              adr_to_replace.reload

              expect(adr.accepted_at).to be_within(1_000).of(Time.now)
              expect(adr_to_replace.replaced_by_adr_id).to eq(adr.id)
            end
          end
        end
      end
    end
  end
end
