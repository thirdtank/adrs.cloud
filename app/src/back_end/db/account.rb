class DB::Account < AppDataModel
  has_external_id :acc

  raise_on_save_failure = true

  one_to_many :adrs
  one_to_many :external_accounts
  one_to_one :entitlement
  one_to_many :projects

  def deactivated? = !!self.deactivated_at

  def external_account(provider:)
    self.external_accounts_dataset.first(provider:)
  end
end
