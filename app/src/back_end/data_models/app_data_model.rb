module DataModel
end
AppDataModel = Class.new(Sequel::Model)
Sequel::Model.db.extension :pg_array
def AppDataModel.transaction(opts=:use_default,&block)
  if opts == :use_default
    opts = Sequel::Database::OPTS
  end
  Sequel::Model.db.transaction(opts,&block)
end
require_relative "account"
require_relative "adr"
require_relative "proposed_adr_replacement"
