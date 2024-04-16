class Adr < Sequel::Model
  many_to_one :account

  def self.create(...)
    super(...)
    id = self.db["select currval('adrs_id_seq')"]
    self[id: id]
  end
end
