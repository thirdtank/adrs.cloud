require "spec_helper"
RSpec.describe ArchivedProjectsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    it "archives the project and redirects back to the projects page" do

      project               = create(:project)
      flash                 = empty_flash
      authenticated_account = AuthenticatedAccount.new(account:project.account)

      result = handler.handle!(external_id: project.external_id,authenticated_account:,flash:)

      expect(result).to be_routing_for(AccountByExternalIdPage,external_id: authenticated_account.external_id,tab: :projects)
      project.reload
      expect(project.archived_at).not_to eq(nil)


    end
  end
end
