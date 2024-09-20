require "spec_helper"
RSpec.describe DraftAdr do
  describe "::create" do
    it "creates, but does not save, a new DB::Adr" do
      account = create(:account)
      draft_adr = nil
      expect {
        draft_adr = described_class.create(account:)
      }.not_to change { DB::Adr.count }
      expect(draft_adr.external_id).to eq(nil)
    end
  end
  describe "::find" do
    context "adr exists" do
      context "account has access to that adr" do
        it "locates that adr" do
          adr = create(:adr)
          account = adr.account
          draft_adr = described_class.find(account:, external_id: adr.external_id)
          expect(draft_adr.external_id).to eq(adr.external_id)
        end
      end
      context "account does not have access to that adr" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            draft_adr = described_class.find(account:, external_id: adr.external_id)
          }.to raise_error(Sequel::NoMatchingRow)
        end
      end
    end
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          draft_adr = described_class.find(account:, external_id: "foobar")
        }.to raise_error(Sequel::NoMatchingRow)
      end
    end
  end
  describe "#to_h" do
    implementation_is_trivial
  end
  describe "#accept" do
    context "form has no constraint violations" do
      it "sets the ADR as accepted" do
        adr = create(:adr)
        account = adr.account
        params = {
          title: adr.title,
          context: Faker::Lorem.sentence,
          facing:  Faker::Lorem.sentence,
          decision:  Faker::Lorem.sentence,
          neglected:  Faker::Lorem.sentence,
          achieve:  Faker::Lorem.sentence,
          accepting:  Faker::Lorem.sentence,
          because:  Faker::Lorem.sentence,
        }
        form = AcceptedAdrsWithExternalIdForm.new(params:)


        result = described_class.find(account:, external_id: adr.external_id).accept(form:)
        expect(result).to be(form)
        expect(form.constraint_violations?).to eq(false)

        adr.reload

        aggregate_failures do
          expect(adr.accepted_at).to be_within(10).of(Time.now)
          expect(adr.title).to       eq(params[:title])
          expect(adr.context).to     eq(params[:context])
          expect(adr.facing).to      eq(params[:facing])
          expect(adr.decision).to    eq(params[:decision])
          expect(adr.neglected).to   eq(params[:neglected])
          expect(adr.achieve).to     eq(params[:achieve])
          expect(adr.accepting).to   eq(params[:accepting])
          expect(adr.because).to     eq(params[:because])
        end
      end
      it "sets the ADR this one is to replaced as having been replaced" do
        adr_to_replace = create(:adr, :accepted)
        account = adr_to_replace.account
        adr = create(:adr, account: account)

        DB::ProposedAdrReplacement.create(
          replacing_adr_id: adr.id,
          replaced_adr_id: adr_to_replace.id
        )

        params = {
          title: adr.title,
          context: Faker::Lorem.sentence,
          facing:  Faker::Lorem.sentence,
          decision:  Faker::Lorem.sentence,
          neglected:  Faker::Lorem.sentence,
          achieve:  Faker::Lorem.sentence,
          accepting:  Faker::Lorem.sentence,
          because:  Faker::Lorem.sentence,
        }
        form = AcceptedAdrsWithExternalIdForm.new(params:)

        result = described_class.find(account:, external_id: adr.external_id).accept(form:)
        expect(result).to be(form)
        expect(form.constraint_violations?).to eq(false)

        adr.reload
        adr_to_replace.reload

        aggregate_failures do
          expect(adr.accepted_at).to be_within(10).of(Time.now)
          expect(adr_to_replace.replaced_by_adr).to eq(adr)
        end
      end
    end
    context "form has client-side constraint violations" do
      it "returns the form and does not change the ADR" do
        adr = create(:adr)
        account = adr.account
        form = AcceptedAdrsWithExternalIdForm.new

        result = described_class.find(account:, external_id: adr.external_id).accept(form:)
        expect(result).to be(form)
        expect(form.constraint_violations?).to eq(true)
        expect(form).to have_constraint_violation(:title, key: :value_missing)
      end
    end
    context "form has server-side constraint violations" do
      it "returns the form and does not change the ADR" do
        adr = create(:adr)
        account = adr.account
        form = AcceptedAdrsWithExternalIdForm.new(params: { title: "some adr title", facing: "short" })

        result = described_class.find(account:, external_id: adr.external_id).accept(form:)
        expect(result).to be(form)
        expect(form.constraint_violations?).to eq(true)
        aggregate_failures do
          expect(form).to have_constraint_violation(:context   , key: :required)
          expect(form).to have_constraint_violation(:facing    , key: :too_short)
          expect(form).to have_constraint_violation(:decision  , key: :required)
          expect(form).to have_constraint_violation(:neglected , key: :required)
          expect(form).to have_constraint_violation(:achieve   , key: :required)
          expect(form).to have_constraint_violation(:accepting , key: :required)
          expect(form).to have_constraint_violation(:because   , key: :required)
        end
      end
    end
  end
  describe "#reject!" do
    it "updates the rejected_at date" do
      adr = create(:adr)
      draft_adr = DraftAdr.find(account: adr.account, external_id: adr.external_id)

      draft_adr.reject!
      adr.reload

      expect(adr.rejected_at).to be_within(10).of(Time.now)
    end
  end
  describe "#save" do
    context "new ADR" do
      context "form has no constraint violations" do
        it "saves the ADR" do
          account = create(:account)
          params = {
            title: Faker::Lorem.sentence,
            context: Faker::Lorem.sentence,
            facing:  Faker::Lorem.sentence,
            decision:  Faker::Lorem.sentence,
            neglected:  Faker::Lorem.sentence,
            achieve:  Faker::Lorem.sentence,
            accepting:  Faker::Lorem.sentence,
            because:  Faker::Lorem.sentence,
          }
          form = NewDraftAdrForm.new(params: params)

          draft_adr = described_class.create(account:)
          result = draft_adr.save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(false)

          adr = DB::Adr.find!(external_id: draft_adr.external_id)
          expect(adr).not_to eq(nil)

          aggregate_failures do
            expect(adr.title).to       eq(params[:title])
            expect(adr.context).to     eq(params[:context])
            expect(adr.facing).to      eq(params[:facing])
            expect(adr.decision).to    eq(params[:decision])
            expect(adr.neglected).to   eq(params[:neglected])
            expect(adr.achieve).to     eq(params[:achieve])
            expect(adr.accepting).to   eq(params[:accepting])
            expect(adr.because).to     eq(params[:because])
            expect(adr.created_at).to  be_within(10).of(Time.now)
            expect(adr.accepted_at).to eq(nil)
          end
        end
        it "marks this ADR as being proposed to replace another one" do
          adr_to_replace = create(:adr, :accepted)
          account = adr_to_replace.account
          params = {
            title: Faker::Lorem.sentence,
            context: Faker::Lorem.sentence,
            facing:  Faker::Lorem.sentence,
            decision:  Faker::Lorem.sentence,
            neglected:  Faker::Lorem.sentence,
            achieve:  Faker::Lorem.sentence,
            accepting:  Faker::Lorem.sentence,
            because:  Faker::Lorem.sentence,
            replaced_adr_external_id: adr_to_replace.external_id
          }
          form = NewDraftAdrForm.new(params: params)

          draft_adr = described_class.create(account:)
          result = draft_adr.save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(false)

          adr = DB::Adr.find!(external_id: draft_adr.external_id)
          expect(adr).not_to eq(nil)
          expect(adr.proposed_to_replace_adr).to eq(adr_to_replace)
        end
        it "if this ADR is being proposed to replace another one, does not create a new proposal" do
          adr_to_replace = create(:adr, :accepted)
          account = adr_to_replace.account
          params = {
            title: Faker::Lorem.sentence,
            context: Faker::Lorem.sentence,
            facing:  Faker::Lorem.sentence,
            decision:  Faker::Lorem.sentence,
            neglected:  Faker::Lorem.sentence,
            achieve:  Faker::Lorem.sentence,
            accepting:  Faker::Lorem.sentence,
            because:  Faker::Lorem.sentence,
            replaced_adr_external_id: adr_to_replace.external_id
          }
          form = NewDraftAdrForm.new(params: params)

          draft_adr = described_class.create(account:)
          result = draft_adr.save(form:)
          expect {
            draft_adr.save(form:)
          }.not_to change {
            DB::ProposedAdrReplacement.count
          }
        end
        it "if this ADR is being proposed to replace another one, and the proposed replacement changes, raises a bug" do
          adr_to_replace = create(:adr, :accepted)
          account = adr_to_replace.account
          other_adr = create(:adr, :accepted, account: account)
          params = {
            title: Faker::Lorem.sentence,
            context: Faker::Lorem.sentence,
            facing:  Faker::Lorem.sentence,
            decision:  Faker::Lorem.sentence,
            neglected:  Faker::Lorem.sentence,
            achieve:  Faker::Lorem.sentence,
            accepting:  Faker::Lorem.sentence,
            because:  Faker::Lorem.sentence,
            replaced_adr_external_id: adr_to_replace.external_id
          }
          form = NewDraftAdrForm.new(params: params)

          draft_adr = described_class.create(account:)
          result = draft_adr.save(form:)
          expect {
            form = EditDraftAdrWithExternalIdForm.new(params: params.merge({
              replaced_adr_external_id: other_adr.external_id,
            }))
            draft_adr.save(form:)
          }.to raise_error(Brut::BackEnd::Errors::Bug)
        end
      end
      context "form has client-side constraint violations" do
        it "returns the form and does not change the ADR" do
          account = create(:account)
          form = NewDraftAdrForm.new

          result = described_class.create(account:).save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:title, key: :value_missing)
        end
      end
      context "form has server-side constraint violations" do
        it "returns the form and does not change the ADR" do
          adr = create(:adr)
          account = adr.account
          form = NewDraftAdrForm.new(params: { title: "some" })

          result = described_class.create(account:).save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:title, key: :not_enough_words)
        end
      end
    end
    context "updating existing ADR" do
      context "form has no constraint violations" do
        it "saves the ADR" do
          adr = create(:adr)
          account = adr.account
          params = {
            title: Faker::Lorem.sentence,
            context: Faker::Lorem.sentence,
            facing:  Faker::Lorem.sentence,
            decision:  Faker::Lorem.sentence,
            neglected:  Faker::Lorem.sentence,
            achieve:  Faker::Lorem.sentence,
            accepting:  Faker::Lorem.sentence,
            because:  Faker::Lorem.sentence,
          }
          form = EditDraftAdrWithExternalIdForm.new(params:)

          draft_adr = described_class.find(account:, external_id: adr.external_id)
          result = draft_adr.save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(false)

          adr.reload

          aggregate_failures do
            expect(adr.title).to       eq(params[:title])
            expect(adr.context).to     eq(params[:context])
            expect(adr.facing).to      eq(params[:facing])
            expect(adr.decision).to    eq(params[:decision])
            expect(adr.neglected).to   eq(params[:neglected])
            expect(adr.achieve).to     eq(params[:achieve])
            expect(adr.accepting).to   eq(params[:accepting])
            expect(adr.because).to     eq(params[:because])
            expect(adr.created_at).to  be_within(10).of(Time.now)
            expect(adr.accepted_at).to eq(nil)
          end
        end
        context "adr has been proposed to replace another one" do
          it "does not allow the proposal to be changed" do
            adr_to_replace = create(:adr, :accepted)
            account        = adr_to_replace.account
            adr            = create(:adr, account: account)
            other_adr      = create(:adr, :accepted, account: account)

            DB::ProposedAdrReplacement.create(
              replacing_adr_id: adr.id,
              replaced_adr_id: adr_to_replace.id,
            )

            params = {
              title: Faker::Lorem.sentence,
              replaced_adr_external_id: other_adr.external_id
            }
            form = EditDraftAdrWithExternalIdForm.new(params:)

            expect {
              described_class.find(account:, external_id: adr.external_id).save(form:)
            }.to raise_error(Brut::BackEnd::Errors::Bug)
          end
        end
        context "adr has not been proposed to replace another one" do
          it "does not allow a proposal to be created" do
            adr_to_replace = create(:adr, :accepted)
            account = adr_to_replace.account
            adr = create(:adr, account: account)
            params = {
              title: Faker::Lorem.sentence,
              replaced_adr_external_id: adr_to_replace.external_id
            }
            form = EditDraftAdrWithExternalIdForm.new(params:)

            expect {
              described_class.find(account:, external_id: adr.external_id).save(form:)
            }.to raise_error(Brut::BackEnd::Errors::Bug)
          end
        end
        context "adr is a refinement of another ADR" do
          it "may not change which ADR it refines" do
            adr_to_refine = create(:adr, :accepted)
            account       = adr_to_refine.account
            adr           = create(:adr, account: account, refines_adr_id: adr_to_refine.id)
            other_adr     = create(:adr, :accepted, account: account)

            params = {
              title: Faker::Lorem.sentence,
              refines_adr_external_id: other_adr.external_id,
            }
            form = EditDraftAdrWithExternalIdForm.new(params:)

            expect {
              described_class.find(account:, external_id: adr.external_id).save(form:)
            }.to raise_error(Brut::BackEnd::Errors::Bug)
          end
        end
        context "adr is not a refinement of another ADR" do
          it "may not set an ADR to refines" do
            adr_to_refine = create(:adr, :accepted)
            account       = adr_to_refine.account
            adr           = create(:adr, account: account)

            params = {
              title: Faker::Lorem.sentence,
              refines_adr_external_id: adr_to_refine.external_id,
            }
            form = EditDraftAdrWithExternalIdForm.new(params:)

            expect {
              described_class.find(account:, external_id: adr.external_id).save(form:)
            }.to raise_error(Brut::BackEnd::Errors::Bug)
          end
        end
      end
      context "form has client-side constraint violations" do
        it "returns the form and does not change the ADR" do
          adr = create(:adr)
          account = adr.account
          form = EditDraftAdrWithExternalIdForm.new

          result = described_class.find(account:,external_id: adr.external_id).save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:title, key: :value_missing)
        end
      end
      context "form has server-side constraint violations" do
        it "returns the form and does not change the ADR" do
          adr = create(:adr)
          account = adr.account
          form = EditDraftAdrWithExternalIdForm.new(params: { title: "title" })

          result = described_class.find(account:, external_id: adr.external_id).save(form:)
          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:title, key: :not_enough_words)
        end
      end
    end
  end
end
RSpec.describe DraftAdr::AcceptedAdrValidator do
  implementation_is_trivial
end
