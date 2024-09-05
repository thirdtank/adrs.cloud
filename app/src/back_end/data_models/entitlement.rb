class DataModel::Entitlement < AppDataModel
  raise_on_save_failure = true

  many_to_one :entitlement_default
  many_to_one :account

  def self.create(...)
    super(...)
    id = self.db["select currval('entitlements_id_seq')"]
    self[id: id]
  end
end

