class DataModel::Account < AppDataModel
  raise_on_save_failure = true

  one_to_many :adrs
  one_to_one :entitlement

  def self.create(...)
    super(...)
    id = self.db["select currval('accounts_id_seq')"]
    self[id: id]
  end
end

