class Actions::Adrs::UpdateTags < AppAction

  def call(form:, account:)
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise "account does not have an ADR with that ID"
    end
    tags = form.tags.split(/\n/).map { |line|
      line.split(/,/)
    }.flatten.map(&:strip).map(&:downcase).uniq
    adr.update(tags: tags)
  end

end

