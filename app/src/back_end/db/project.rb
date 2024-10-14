class DB::Project < AppDataModel
  has_external_id :prj
  many_to_one :account
  one_to_many :adrs
end
