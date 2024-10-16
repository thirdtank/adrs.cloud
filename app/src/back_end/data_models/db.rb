module DB
  def self.transaction(opts=:use_default,&block)
    if opts == :use_default
      opts = Sequel::Database::OPTS
    end
    Sequel::Model.db.transaction(opts,&block)
  end
end
