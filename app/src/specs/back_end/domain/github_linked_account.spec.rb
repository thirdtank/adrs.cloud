require "spec_helper"
RSpec.describe GithubLinkedAccount do
  describe "::search_from_omniauth_hash" do
    it "raises an error if the provider is not 'github'" do
      account = create(:account)
      omniauth_hash = {
        "provider" => "gitlab",
        "uid" => SecureRandom.uuid,
        "info" => {
          "email" => account.email
        }
      }
      expect {
        GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
      }.to raise_error(/was asked to process a 'gitlab'/i)
    end
    it "raises an error if there is no uid" do
      account = create(:account)
      omniauth_hash = {
        "provider" => "github",
        "uid" => nil,
        "info" => {
          "email" => account.email
        }
      }
      expect {
        GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
      }.to raise_error(/did not get a uid/i)
    end
    it "raises an error if there is no email" do
      account = create(:account)
      omniauth_hash = {
        "provider" => "github",
        "uid" => SecureRandom.uuid,
        "info" => {
          "email" => nil,
        }
      }
      expect {
        GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
      }.to raise_error(/did not get an email/i)
    end
    context "email exists" do
      context "the account does not have an ExternalAccount for GitHub" do
        context "there is no ExternalAccount with this uid" do
          it "creates an ExternalAccount for this account, then returns a GithubLinkedAccount" do
            account = create(:account)

            omniauth_hash = {
              "provider" => "github",
              "uid" => SecureRandom.uuid,
              "info" => {
                "email" => account.email
              }
            }

            github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
            new_external_account = DB::ExternalAccount[account: account, provider: "github"]

            expect(github_linked_account).not_to                eq(nil)
            expect(github_linked_account.session_id).to         eq(account.external_id)
            expect(new_external_account).not_to                 eq(nil)
            expect(new_external_account.external_account_id).to eq(omniauth_hash["uid"])
          end
        end
        context "there is already an ExternalAccount with this uid" do
          it "returns an InternalErrorAccount" do
            account                = create(:account)
            other_external_account = create(:external_account, provider: "github")

            omniauth_hash = {
              "provider" => "github",
              "uid" => other_external_account.external_account_id,
              "info" => {
                "email" => account.email
              }
            }

            github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)

            expect(github_linked_account.error?).to eq(true)
            expect(github_linked_account.error_i18n_key).to eq("domain.account.github.uid_used_by_other_account")
          end
        end
      end
      context "the account does have an ExternalAccount for GitHub" do
        context "the uid matches the ExternalAccount" do
          it "returns a GithubLinkedAccount whose session id is the Account's external_id" do

            account          = create(:account)
            external_account = create(:external_account, account: account, provider: "github")

            omniauth_hash = {
              "provider" => "github",
              "uid" => external_account.external_account_id,
              "info" => {
                "email" => account.email
              }
            }

            github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
            expect(github_linked_account).not_to eq(nil)
            expect(github_linked_account.session_id).to eq(account.external_id)
          end
        end
        context "the uid does not match the ExternalAccount" do
          it "returns an InternalErrorAccount" do
            account          = create(:account)
            external_account = create(:external_account, account: account, provider: "github")

            omniauth_hash = {
              "provider" => "github",
              "uid" => SecureRandom.uuid,
              "info" => {
                "email" => account.email
              }
            }

            github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)

            expect(github_linked_account.error?).to eq(true)
            expect(github_linked_account.error_i18n_key).to eq("domain.account.github.uid_changed")
          end
        end
      end
    end
    context "email does not exist" do
      it "returns nil" do
        omniauth_hash = {
          "provider" => "github",
          "uid" => SecureRandom.uuid,
          "info" => {
            "email" => "foo@blah.com",
          }
        }

        github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
        expect(github_linked_account).to eq(nil)
      end
    end
    context "email exists, but is deactivated" do
      it "returns a DeactivateAccount" do
        account = create(:account, :deactivated)
        omniauth_hash = {
          "provider" => "github",
          "uid" => SecureRandom.uuid,
          "info" => {
            "email" => account.email
          }
        }

        github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash:)
        expect(github_linked_account).not_to eq(nil)
        expect(github_linked_account.active?).to eq(false)
      end
    end
  end
  describe "::search" do
    context "email is not in the database" do
      it "returns that it does not exist" do
        linked_account = GithubLinkedAccount.find(email: "nope@nope.nope")
          expect(linked_account).to eq(nil)
      end
    end
    context "email is in the database" do
      context "account is not deactivated" do
        it "returns that it exists" do
          account = create(:account, :active)
          linked_account = GithubLinkedAccount.find(email: account.email)
          expect(linked_account.account.id).to eq(account.id)
        end
      end
      context "account is deactivated" do
        it "returns that it does not exist" do
          account = create(:account, :deactivated)

          linked_account = GithubLinkedAccount.find(email: account.email)

          expect(linked_account).not_to     eq(nil)
          expect(linked_account.active?).to eq(false)
        end
      end
    end
  end
  describe "#deactivate!" do
    it "sets deactivated_at and rotates their external_id" do
      account = create(:account, :active)
      external_id = account.external_id
      github_linked_account = described_class.new(account:)
      github_linked_account.deactivate!

      account.reload
      expect(account.deactivated?).to eq(true)
      expect(account.external_id).not_to eq(external_id)
    end
  end
  describe "::create" do
    context "email already exists" do
      context "active" do
        it "marks an error on the form" do
          account = create(:account, :active)
          form = Admin::NewAccountForm.new(params: { email: account.email })

          result = described_class.create(form:)

          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:email, key: :account_exists)
        end
      end
      context "not-active" do
        it "marks an error on the form" do
          account = create(:account, :deactivated)
          form = Admin::NewAccountForm.new(params: { email: account.email })

          result = described_class.create(form:)

          expect(result).to be(form)
          expect(form.constraint_violations?).to eq(true)
          expect(form).to have_constraint_violation(:email, key: :account_deactivated)
        end
      end
    end
    context "email doesn't exist" do
      it "creates a new account with default entitlements and one project" do
        form = Admin::NewAccountForm.new(params: { email: Faker::Internet.unique.email })

        result = nil
        expect {
          result = described_class.create(form:)
        }.to change {
          DB::Account.count
        }.by(1)

        new_account = DB::Account.find!(email: form.email)

        expect(result).not_to be(form)
        expect(form.constraint_violations?).to eq(false)
        expect(result.session_id).to eq(new_account.external_id)
        expect(new_account.projects.size).to eq(1)
        expect(new_account.projects[0].name).to eq("Default")
      end
    end
  end
end
