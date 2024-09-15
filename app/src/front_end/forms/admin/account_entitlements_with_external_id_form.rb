module Admin
  class AccountEntitlementsWithExternalIdForm < AppForm
    input :max_non_rejected_adrs, required: false, type: :number, min: 5, max: 100, step: 1
  end
end
