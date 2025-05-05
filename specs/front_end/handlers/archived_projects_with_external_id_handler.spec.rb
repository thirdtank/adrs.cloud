require "spec_helper"
RSpec.describe ArchivedProjectsWithExternalIdHandler do
  describe "#handle!" do
    it "archives the project and redirects back to the projects page" do
      project = create(:project)
      external_id = project.external_id
      authenticated_account = AuthenticatedAccount.new(account: project.account)
      flash = empty_flash
      handler = described_class.new(external_id: external_id, authenticated_account: authenticated_account, flash: flash)

      result = handler.handle!

      expect(result).to be_routing_for(AccountByExternalIdPage, external_id: authenticated_account.external_id, tab: :projects)
      project.reload
      expect(project.archived_at).not_to eq(nil)
    end
  end
end
