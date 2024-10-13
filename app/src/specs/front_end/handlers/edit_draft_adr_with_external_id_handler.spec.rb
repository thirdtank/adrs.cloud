require "spec_helper"
RSpec.describe EditDraftAdrWithExternalIdHandler do
  context "normal web request" do
    context "constraint violations" do
      it "renders the EditDraftAdrByExternalIdPage" do
        authenticated_account = create(:authenticated_account)
        adr = create(:adr, account: authenticated_account.account)
        adr.title = "aaaaa"
        form = EditDraftAdrWithExternalIdForm.new(params: { title: adr.title })
        flash = empty_flash

        result = described_class.new.handle!(form: form,
                                             external_id: adr.external_id,
                                             authenticated_account:,
                                             xhr: false,
                                             flash:)

        expect(result.class).to eq(EditDraftAdrByExternalIdPage)
        expect(flash.alert).to eq(:update_adr_invalid)
        expect(result.form).to eq(form)
      end
    end
    context "no constraint violations" do
      it "redirects to the AdrsByExternalIdPage" do
        authenticated_account = create(:authenticated_account)
        adr = create(:adr, account: authenticated_account.account, project: authenticated_account.account.projects.first)
        form = EditDraftAdrWithExternalIdForm.new(params: {
          title: adr.title,
          project_external_id: adr.project.external_id,
        })

        result = described_class.new.handle!(form: form,
                                             external_id: adr.external_id,
                                             authenticated_account:,
                                             xhr: false,
                                             flash: empty_flash)

        expect(result).to be_routing_for(AdrsByExternalIdPage,external_id: adr.external_id)
      end
    end
  end
  context "xhr request" do
    context "constraint violations" do
      it "renders the Adr::ErrorMessagesComponent with status 422" do
        authenticated_account = create(:authenticated_account)
        adr = create(:adr, account: authenticated_account.account)
        adr.title = "aaaaa"
        form = EditDraftAdrWithExternalIdForm.new(params: { title: adr.title })

        result = described_class.new.handle!(form: form,
                                             external_id: adr.external_id,
                                             authenticated_account:,
                                             xhr: true,
                                             flash: empty_flash)

        expect(result.class).to eq(Array)
        expect(result[0].class).to eq(ErrorMessagesComponent)
        expect(result[0].form).to eq(form)
        expect(result[1].to_i).to eq(422)
      end
    end
    context "no constraint violations" do
      it "returns an HTTP 200" do
        authenticated_account = create(:authenticated_account)
        adr = create(:adr, account: authenticated_account.account, project: authenticated_account.account.projects.first)
        form = EditDraftAdrWithExternalIdForm.new(params: {
          title: adr.title,
          project_external_id: authenticated_account.account.projects.first.external_id,
        })

        result = described_class.new.handle!(form: form,
                                             external_id: adr.external_id,
                                             authenticated_account: authenticated_account,
                                             xhr: true,
                                             flash: empty_flash)

        expect(result.to_i).to eq(200)
      end
    end
  end
end
