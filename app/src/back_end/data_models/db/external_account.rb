class DB::ExternalAccount < AppDataModel
  raise_on_save_failure = true

  many_to_one :account
end
