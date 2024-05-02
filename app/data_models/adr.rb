class DataModel::Adr < AppDataModel
  many_to_one :account

  def self.create(...)
    super(...)
    id = self.db["select currval('adrs_id_seq')"]
    self[id: id]
  end

  def accepted? = !self.accepted_at.nil?
  def rejected? = !self.rejected_at.nil?
end
