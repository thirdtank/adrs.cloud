require "spec_helper"
require "back_end/actions/adrs/update_tags"

RSpec.describe Actions::Adrs::UpdateTags do
  subject(:update_tags) { described_class.new }

  describe "#update" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(external_id: "foobar")
        expect {
          update_tags.update(form: form, account: account)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          form = Forms::Adrs::Draft.new(external_id: adr.external_id)
          expect {
            update_tags.update(form: form, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "account has access" do
        it "updates the tags based on the form's string of tags" do
          adr = create(:adr)
          account = adr.account
          form = Forms::Adrs::Draft.new(external_id: adr.external_id, tags: "foo, bar\nBLAH")
          return_value = update_tags.update(form: form, account: account)

          adr.reload
          expect(adr.tags).to eq([ "foo", "bar", "blah" ])
          expect(return_value.id).to eq(adr.id)
        end
      end
    end
  end

end
