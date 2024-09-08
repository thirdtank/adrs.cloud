class DataModel::Account < AppDataModel
  raise_on_save_failure = true

  one_to_many :adrs
  one_to_one :entitlement
end
