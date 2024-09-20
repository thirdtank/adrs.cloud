class DB::Account < AppDataModel
  has_external_id :acc

  raise_on_save_failure = true

  one_to_many :adrs
  one_to_one :entitlement

  def deactivated? = !!self.deactivated_at
end
