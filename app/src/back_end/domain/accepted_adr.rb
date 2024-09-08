class AcceptedAdr
  def self.find(external_id:,account:)
    adr = DataModel::Adr.first(Sequel.lit("external_id = ? and account_id = ? and accepted_at is not null",external_id,account.id))

    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{external_id}"
    end
    AcceptedAdr.new(adr:)
  end

  def initialize(adr:)
    @adr = adr
  end

  def update_tags(form:)
    @adr.update(tags: Tags.from_string(string: form.tags).to_a)
  end

  def stop_sharing!
    @adr.update(shareable_id: nil)
  end

  def share!
    random_hex = SecureRandom.hex
    @adr.update(shareable_id: "padr_#{random_hex}")
  end
end
