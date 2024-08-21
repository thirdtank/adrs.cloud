require "securerandom"

class Actions::Adrs::Public
  def make_public(external_id:, account:)
    adr = require_account_own_adr!(external_id,account)
    random_hex = SecureRandom.hex
    adr.update(public_id: "padr_#{random_hex}")
  end
  def make_private(external_id:, account:)
    adr = require_account_own_adr!(external_id,account)
    adr.update(public_id: nil)
  end

private

  def require_account_own_adr!(external_id,account)
    adr = DataModel::Adr[external_id: external_id, account_id: account.id]
    if adr.nil?
      raise "This account does not own this adr"
    end
    adr
  end
end
