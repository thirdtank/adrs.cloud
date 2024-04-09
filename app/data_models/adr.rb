class Adr < Sequel::Model
  many_to_one :account
end
