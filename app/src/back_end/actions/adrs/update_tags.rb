class Actions::Adrs::UpdateTags

  def update(form:, account:)
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise "account does not have an ADR with that ID"
    end
    adr.update(tags: tag_serializer.from_string(form.tags))
    adr
  end

private

  def tag_serializer
    @tag_serializer ||= Actions::Adrs::TagSerializer.new
  end

end

