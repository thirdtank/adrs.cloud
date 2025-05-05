require "spec_helper"
RSpec.describe Admin::NewAccountHandler do
  describe "#handle!" do
    context "authenticated_account does not have admin access" do
      it "404s" do
        authenticated_account = create(:authenticated_account)
        account = create(:account)
        form = Admin::NewAccountForm.new
        flash = empty_flash
        handler = described_class.new(form: form, flash: flash, authenticated_account: authenticated_account)

        result = handler.handle!
        expect(result).to have_returned_http_status(404)
      end
    end
    context "authenticated_account has admin access" do
      context "account with that email already exist" do
        it "renders the admin home page with errors" do
          authenticated_account = create(:authenticated_account, :admin)
          account = create(:account)
          form = Admin::NewAccountForm.new(params: { email: account.email })
          flash = empty_flash
          handler = described_class.new(form: form, flash: flash, authenticated_account: authenticated_account)

          result = handler.handle!

          expect(result.class).to eq(Admin::HomePage)
          expect(result.new_account_form).to eq(form)
        end
      end
      context "account with that email does not exist" do
        it "redirects to the adminhome page" do
          authenticated_account = create(:authenticated_account, :admin)
          form = Admin::NewAccountForm.new(params: { email: Faker::Internet.unique.email })

          flash = empty_flash
          handler = described_class.new(form: form, flash: flash, authenticated_account: authenticated_account)

          result = handler.handle!

          expect(result).to be_routing_for(Admin::HomePage)
          expect(flash.notice).to eq("account_created")
        end
      end
    end
  end
end
