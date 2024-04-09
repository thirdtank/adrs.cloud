class Account < Sequel::Model
  raise_on_save_falure = true

  one_to_many :adrs

  def self.create(...)
    super(...)
    id = self.db["select currval('accounts_id_seq')"]
    self[id: id]
  end
end

