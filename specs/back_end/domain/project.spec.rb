require "spec_helper"
RSpec.describe Project do
  describe "::find!" do
    it "raises an error if the project cannot be found" do
      project = create(:project)
      account = create(:account)

      expect {
        Project.find!(external_id: project.external_id,account: account)
      }.to raise_error(Sequel::NoMatchingRow)
    end
  end
  describe "::create" do
    context "account has not reached limit" do
      it "creates an unsaved project" do
        account = create(:account)
        account.entitlement.update(max_projects: 3)
        project = Project.create(authenticated_account: AuthenticatedAccount.new(account:))
        expect(project.external_id).to eq(nil)
        expect(project.account).to eq(account)
      end
    end
    context "account has reached limit" do
      it "raises an error" do
        account = create(:account)
        account.entitlement.update(max_projects: 3)
        create(:project, account: account)
        create(:project, account: account)
        expect {
          Project.create(authenticated_account: AuthenticatedAccount.new(account:))
        }.to be_a_bug
      end
    end
  end
  describe "#save" do
    context "name in use by another project in this account" do
      context "new project" do
        it "marks a server-side constraint violation" do
          authenticated_account = create(:authenticated_account)
          project = Project.create(authenticated_account:)
          form = NewProjectForm.new(params: {
            name: authenticated_account.account.projects.first.name,
            description: "Some details",
            adrs_shared_by_default: false,
          })
          expect {
            project.save(form:)
          }.not_to change {
            DB::Project.count
          }

          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:name,key: :taken)
        end
      end
      context "existing project" do
        it "marks a server-side constraint violation" do
          authenticated_account = create(:authenticated_account)
          existing_project = authenticated_account.account.projects.first
          db_project = create(:project,account: authenticated_account.account)
          project = Project.find!(account: authenticated_account.account,external_id: db_project.external_id)

          form = NewProjectForm.new(params: {
            name: existing_project.name,
            description: "Some details",
            adrs_shared_by_default: false,
          })
          expect {
            project.save(form:)
          }.not_to change {
            DB::Project.count
          }

          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:name,key: :taken)
        end
      end
    end
    context "name not in use" do
      context "new project" do
        it "creates the project" do
          authenticated_account = create(:authenticated_account)
          project = Project.create(authenticated_account:)
          form = project.save(form: NewProjectForm.new(params: {
            name: "This Old House Project",
            description: "Some details",
            adrs_shared_by_default: false,
          }))

          expect(form.constraint_violations?).to eq(false)

          created_project = DB::Project.find(name: form.name, account: authenticated_account.account)

          expect(created_project).not_to eq(nil)
          aggregate_failures do
            expect(created_project.name).to                   eq(form.name)
            expect(created_project.description).to            eq(form.description)
            expect(created_project.adrs_shared_by_default).to eq(false)
          end
        end
      end
      context "existing project" do
        it "updates the project" do
          authenticated_account = create(:authenticated_account)
          db_project = create(:project,account: authenticated_account.account)
          project = Project.find!(account: authenticated_account.account,external_id: db_project.external_id)

          form = NewProjectForm.new(params: {
            name: db_project.name,
            description: "Some changed details",
            adrs_shared_by_default: true,
          })
          project.save(form:)

          expect(form.constraint_violations?).to eq(false)
          db_project.reload
          aggregate_failures do
            expect(db_project.name).to                   eq(form.name)
            expect(db_project.description).to            eq(form.description)
            expect(db_project.adrs_shared_by_default).to eq(true)
          end
        end
      end
    end
  end
  describe "#archive" do
    context "project already archived" do
      it "raises an error" do
        authenticated_account = create(:authenticated_account)
        db_project = create(:project,:archived,account: authenticated_account.account)
        project = Project.find!(account: authenticated_account.account,external_id: db_project.external_id)
        expect {
          project.archive
        }.to be_a_bug
      end
    end
    context "project has not been saved" do
      it "raises an error" do
        authenticated_account = create(:authenticated_account)
        project = Project.create(authenticated_account:)
        expect {
          project.archive
        }.to be_a_bug
      end
    end
    context "project not archived" do
      it "sets the archived_at date" do
        authenticated_account = create(:authenticated_account)
        db_project = create(:project,account: authenticated_account.account)
        project = Project.find!(account: authenticated_account.account,external_id: db_project.external_id)
        project.archive
        db_project.reload
        expect(db_project.archived_at).to be_within(10).of(Time.now)
      end
    end
  end
end
