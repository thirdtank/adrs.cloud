class DB::EntitlementDefault < AppDataModel
  has_external_id :etd
  raise_on_save_failure = true
end

