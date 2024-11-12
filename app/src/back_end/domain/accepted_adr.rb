class AcceptedAdr

  include Brut::Framework::Errors
  extend Brut::Framework::Errors

  def self.find(external_id:,account:)
    adr = DB::Adr.first(Sequel.lit("external_id = ? and account_id = ? and accepted_at is not null",external_id,account.id))
    if adr.nil?
      return nil
    end
    AcceptedAdr.new(adr:)
  end

  def self.find!(external_id:,account:)
    accepted_adr = self.find(external_id:,account:)
    if accepted_adr.nil?
      raise Brut::Framework::Errors::NotFound.new(resource_name: "ADR",id: external_id,context: "Account #{account.id}")
    end
    accepted_adr
  end

  def title       = @adr.title
  def external_id = @adr.external_id
  def project     = @adr.project

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

  def propose_replacement(adr)
    if !self.class.find(external_id: adr.external_id, account: adr.account).nil?
      bug! "You cannot replace an ADR with an accepted ADR"
    end
    if adr.account != @adr.account
      bug! "You cannot replace an ADR with another account's ADR"
    end
    if adr.project != @adr.project
      bug! "You cannot replace an ADR with another project's ADR (#{adr.project&.id} != #{@adr.project&.id})"
    end
    DB::ProposedAdrReplacement.create(
      replacing_adr_id: adr.id,
      replaced_adr_id: @adr.id,
    )
  end
end
