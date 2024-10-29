require "spec_helper"
RSpec.describe AuthenticatedAccount do
  describe "::find" do
    context "session id is not in the database" do
      it "returns nil" do
        result = AuthenticatedAccount.find(session_id: "blah")

        expect(result).to eq(nil)
      end
    end
    context "session id is in the database" do
      context "account is active" do
        it "returns an AuthenticatedAccount" do
          account = create(:account, :active)
          result = AuthenticatedAccount.find(session_id: account.external_id)

          expect(result).not_to eq(nil)
          expect(result.class).to eq(described_class)
        end
      end
      context "account is deactivated" do
        it "returns a DeactivatedAccount" do
          account = create(:account, :deactivated)
          result = AuthenticatedAccount.find(session_id: account.external_id)

          expect(result).not_to eq(nil)
          expect(result.class).to eq(DeactivatedAccount)
        end
      end
    end
  end

  describe "::new" do
    context "account is active" do
      it "returns an AuthenticatedAccount" do
        account = create(:account, :active)

        authenticated_account = AuthenticatedAccount.new(account:)
        expect(authenticated_account.active?).to eq(true)
        expect(authenticated_account.session_id).to eq(account.external_id)
      end
    end
    context "account is deactivated" do
      it "raises an ArgumentError" do
        account = create(:account, :deactivated)

        expect {
          AuthenticatedAccount.new(account:)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "adrs.search" do
    context "no tag provided" do
      it "returns all ADRs on the account" do
        account = create(:account)
        adrs = Set[
          create(:adr, account:),
          create(:adr, :rejected, account:),
          create(:adr, :rejected, account:),
          create(:adr, :accepted, account:),
          create(:adr, :accepted, account:),
        ]

        results = described_class.new(account:).adrs.search

        expect(results.size).to eq(adrs.size)

        ids_found = results.map(&:id)
        aggregate_failures do
          adrs.each do |adr|
            expect(ids_found).to include(adr.id)
          end
        end
      end
    end
    context "tag provided" do
      context "the tag is the shared tag" do
        it "returns ADRs on the account that are shared" do
          account = create(:account)
          shared1 = create(:adr, :shared,  :accepted, account:)
          shared2 = create(:adr, :shared,  :accepted, account:)

          create(:adr, account:)
          create(:adr, :rejected, account:)
          create(:adr, :rejected, account:)
          create(:adr, :private, :accepted, account:)

          results = described_class.new(account:).adrs.search(tag: DB::Adr.phony_tag_for_shared)

          expect(results.size).to eq(2)

          ids_found = results.map(&:id)
          expect(ids_found).to include(shared1.id)
          expect(ids_found).to include(shared2.id)
        end
      end
      context "the tag is a normal tag" do
        context "no project" do
          it "returns ADRs on the account with that tag" do
            account = create(:account)
            tag     = "test tag"
            tagged1 = create(:adr, account:, tags: [ tag, "foo", "bar" ])
            tagged2 = create(:adr, account:, tags: [ "blah", tag ])

            create(:adr, account:)
            create(:adr, :rejected, account:)
            create(:adr, :rejected, account:)
            create(:adr, :private, :accepted, account:)

            results = described_class.new(account:).adrs.search(tag:)

            expect(results.size).to eq(2)

            ids_found = results.map(&:id)
            expect(ids_found).to include(tagged1.id)
            expect(ids_found).to include(tagged2.id)
          end
        end
        context "project also provided" do
          it "returns ADRs on the account with that tag" do
            account = create(:account)
            project = create(:project, account: account)
            tag     = "test tag"
            tagged1 = create(:adr, account:, project: account.projects.first, tags: [ tag, "foo", "bar" ])
            tagged2 = create(:adr, account:, project: project, tags: [ "blah", tag ])
            tagged3 = create(:adr, account:, project: project, tags: [ "blah", tag ])

            create(:adr, account:)
            create(:adr, :rejected, account:)
            create(:adr, :rejected, account:)
            create(:adr, :private, :accepted, account:)

            results = described_class.new(account:).adrs.search(tag:,project:)

            expect(results.size).to eq(2)

            ids_found = results.map(&:id)
            expect(ids_found).to include(tagged2.id)
            expect(ids_found).to include(tagged3.id)
          end
        end
      end
    end
    context "project provided" do
      it "returns ADRs in that project" do
        account = create(:account)
        project = create(:project, name: account.projects.first.name + " 2",account: account)
        create(:adr, account:, project: account.projects.first)
        in_project_1 = create(:adr, account:, project: project)
        in_project_2 = create(:adr, account:, project: project)

        create(:adr, account:)
        create(:adr, :rejected, account:)
        create(:adr, :rejected, account:)
        create(:adr, :private, :accepted, account:)

        results = described_class.new(account:).adrs.search(project:)

        expect(results.size).to eq(2)

        ids_found = results.map(&:id)
        expect(ids_found).to include(in_project_1.id)
        expect(ids_found).to include(in_project_2.id)
      end
    end
  end
end
