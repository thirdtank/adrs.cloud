require "spec_helper"
RSpec.describe Admin::NewAccountHandler do
  describe "#handle!" do
    subject(:handler) { described_class.new }
    context "account with that email already exist" do
      it "renders the admin home page with errors" do
        account = create(:account)
        form = Admin::NewAccountForm.new(params: { email: account.email })

        result = handler.handle!(form:, flash: empty_flash)

        expect(result.class).to eq(Admin::HomePage)
        expect(result.new_account_form).to eq(form)
      end
    end
    context "account with that email does not exist" do
      it "redirects to the adminhome page" do
        form = Admin::NewAccountForm.new(params: { email: Faker::Internet.unique.email })

        flash = empty_flash
        result = handler.handle!(form:, flash: flash)

        expect(result).to be_routing_for(Admin::HomePage)
        expect(flash.notice).to eq(:account_created)
      end
    end
  end
end
