class Admin::HomePage < AppPage

  attr_reader :new_account_form, :account_search_form
  def initialize
    @new_account_form    = Admin::NewAccountForm.new
    @account_search_form = Admin::AccountSearchForm.new
  end
end
