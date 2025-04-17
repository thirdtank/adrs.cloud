require "spec_helper"

RSpec.describe EditProjectWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "there are constraint violations" do
      it "re-renders the page with the errors" do
        account = create(:account)
        project = account.projects.first
        other_project = create(:project, account: account)

        authenticated_account = AuthenticatedAccount.new(account:)
        form = EditProjectWithExternalIdForm.new(params: {
          name: other_project.name,
          description: "Description of project",
          adrs_shared_by_default: true,
        })
        flash = empty_flash

        result = handler.handle!(external_id:project.external_id,authenticated_account:,form:,flash:)
        expect(form.constraint_violations?).to eq(true)
        expect(form).to have_constraint_violation(:name, key: :taken)
        expect(flash.alert).to eq("save_project_invalid")
        expect(result.class).to eq(EditProjectByExternalIdPage)
        expect(result.form).to eq(form)
      end
    end
    context "there are no constraint violations" do
      it "saves the project and redirects back to the accounts page, projects tab" do
        account = create(:account)
        project = account.projects.first
        authenticated_account = AuthenticatedAccount.new(account:)

        form = EditProjectWithExternalIdForm.new(params: {
          name: project.name,
          description: "Description of project",
          adrs_shared_by_default: true,
        })

        result = handler.handle!(external_id: project.external_id,
                                 authenticated_account:,
                                 form:,
                                 flash:empty_flash)

        expect(result).to be_routing_for(AccountByExternalIdPage, external_id: account.external_id, tab: "projects")
      end
    end
  end
end
