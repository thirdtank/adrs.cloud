class DB::Download < AppDataModel
  has_external_id :dl
  many_to_one :account # really one-to-one
end
