class DB::Entitlement < AppDataModel
  raise_on_save_failure = true

  many_to_one :entitlement_default
  many_to_one :account

end

