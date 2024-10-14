class NewProjectPage < AppPage
  attr_reader :form, :account_external_id
  def initialize(form:nil, authenticated_account:)
    @form                = form || NewProjectForm.new
    @account_external_id = authenticated_account.external_id
  end
end
