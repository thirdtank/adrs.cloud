class Account < Sequel::Model
  raise_on_save_falure = true

  def self.create(...)
    super(...)
    id = self.db["select currval('accounts_id_seq')"]
    self[id: id]
  end

  def adrs = []
end

