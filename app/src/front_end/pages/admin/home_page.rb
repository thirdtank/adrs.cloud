class Admin::HomePage < AppPage

  attr_reader :new_account_form, :account_search_form, :flash
  def initialize(new_account_form:nil,flash:)
    @new_account_form    = new_account_form || Admin::NewAccountForm.new
    @account_search_form = Admin::AccountSearchForm.new
    @flash               = flash
  end
end
