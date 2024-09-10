class Admin::AccountsPage < AppPage

  attr_reader :search_string, :matching_accounts
  def initialize(search_string:)
    @matching_accounts = DataModel::Account.where(Sequel.like(:email,"%#{search_string}%")).to_a
    @search_string = search_string
  end

  def edit_account_path(account)
    Admin::AccountsByExternalIdPage.routing(external_id: account.external_id)
  end
end
