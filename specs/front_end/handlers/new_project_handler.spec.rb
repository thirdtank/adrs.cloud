require "spec_helper"

RSpec.describe NewProjectHandler do
  describe "#handle!" do
    context "there are constraint violations" do
      it "re-renders the page with the errors" do
        account = create(:account)
        authenticated_account = AuthenticatedAccount.new(account: account)
        form = NewProjectForm.new(params: {
          name: account.projects.first.name,
          description: "Description of project",
          adrs_shared_by_default: true,
        })
        flash = empty_flash
        handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

        result = handler.handle!
        expect(form.constraint_violations?).to eq(true)
        expect(form).to have_constraint_violation(:name, key: :taken)
        expect(flash.alert).to eq("new_project_invalid")
        expect(result.class).to eq(NewProjectPage)
        expect(result.form).to eq(form)
      end
    end
    context "there are no constraint violations" do
      it "saves the project and redirects back to the accounts page, projects tab" do
        account = create(:account)
        authenticated_account = AuthenticatedAccount.new(account: account)
        form = NewProjectForm.new(params: {
          name: "Some New Project",
          description: "Description of project",
          adrs_shared_by_default: true,
        })
        flash = empty_flash
        handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

        result = handler.handle!
        expect(result).to be_routing_for(AccountByExternalIdPage, external_id: account.external_id, tab: "projects")
      end
    end
    context "limit on projects exceeded" do
      it "returns a 403 as this should never have been posted to" do
        account = create(:account)
        account.entitlement.update(max_projects: 3)
        create(:project, account: account)
        create(:project, account: account) # + 1 that is created with create(:account)

        authenticated_account = AuthenticatedAccount.new(account: account)
        form = NewProjectForm.new(params: {
          name: "Some New Project",
          description: "Description of project",
          adrs_shared_by_default: true,
        })
        flash = empty_flash
        handler = described_class.new(form: form, authenticated_account: authenticated_account, flash: flash)

        result = handler.handle!
        expect(result.to_i).to eq(403)
      end
    end
  end
end
