class DB::Project < AppDataModel
  has_external_id :prj
  many_to_one :account
  one_to_many :adrs

  def as_json(*args)
    hash = self.to_hash.slice(
      :external_id,
      :name,
      :description,
      :adrs_shared_by_default,
      :archived_at,
    )
    hash
  end
end
