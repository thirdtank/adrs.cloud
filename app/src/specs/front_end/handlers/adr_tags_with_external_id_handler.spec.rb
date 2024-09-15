require "spec_helper"
RSpec.describe AdrTagsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        form = AdrTagsWithExternalIdForm.new
        expect {
          handler.handle!(form: form, external_id: "foobar", account: account, flash: empty_flash)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          form = AdrTagsWithExternalIdForm.new
          expect {
            handler.handle!(form: form, external_id: adr.external_id, account: account, flash: empty_flash)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "account has access" do
        it "updates the tags based on the form's string of tags" do
          adr     = create(:adr, :accepted)
          account = adr.account
          form    = AdrTagsWithExternalIdForm.new(params: { tags: "foo, bar\nBLAH" })
          flash   = empty_flash

          return_value = handler.handle!(form: , account: ,flash:, external_id: adr.external_id)

          expect(return_value).to be_routing_for(AdrsByExternalIdPage,external_id: adr.external_id)

          adr.reload
          expect(adr.tags).to eq([ "foo", "bar", "blah" ])
        end
      end
    end
  end
end
