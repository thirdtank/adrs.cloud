module DB
  def self.transaction(opts=:use_default,&block)
    if opts == :use_default
      opts = Sequel::Database::OPTS
    end
    Sequel::Model.db.transaction(opts,&block)
  end
end
AppDataModel = Class.new(Sequel::Model)

Sequel::Model.db.extension :pg_array
Sequel::Model.plugin :external_id, global_prefix: "ad"
Sequel::Model.plugin :find_bang
Sequel::Model.plugin :created_at

require_relative "account"
require_relative "external_account"
require_relative "adr"
require_relative "proposed_adr_replacement"
require_relative "entitlement"
require_relative "entitlement_default"
