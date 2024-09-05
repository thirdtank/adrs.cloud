class DataModel::EntitlementDefault < AppDataModel
  raise_on_save_failure = true

  def self.create(...)
    super(...)
    id = self.db["select currval('entitlement_defaults_id_seq')"]
    self[id: id]
  end
end

