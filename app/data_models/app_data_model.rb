module DataModel
end
AppDataModel = Class.new(Sequel::Model)
require_relative "account"
require_relative "adr"
