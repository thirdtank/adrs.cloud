class Admin::AccountsPage < Admin::BasePage

  attr_reader :search_string, :matching_accounts
  def initialize(authenticated_account:, search_string:)
    super(authenticated_account:)
    @matching_accounts = DB::Account.where(Sequel.like(:email,"%#{search_string}%")).to_a
    @search_string = search_string
  end

  def edit_account_path(account)
    Admin::AccountsByExternalIdPage.routing(external_id: account.external_id)
  end
end
