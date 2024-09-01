require "securerandom"

class Actions::Adrs::Share
  def share(external_id:, account:)
    adr = require_account_own_adr!(external_id,account)
    random_hex = SecureRandom.hex
    adr.update(shareable_id: "padr_#{random_hex}")
    adr
  end
  def stop_sharing(external_id:, account:)
    adr = require_account_own_adr!(external_id,account)
    adr.update(shareable_id: nil)
    adr
  end

private

  def require_account_own_adr!(external_id,account)
    adr = DataModel::Adr[external_id: external_id, account_id: account.id]
    if adr.nil?
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{external_id}"
    end
    adr
  end
end
