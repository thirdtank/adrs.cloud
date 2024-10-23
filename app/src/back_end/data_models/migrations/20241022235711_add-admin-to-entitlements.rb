Sequel.migration do
  up do
    add_column :entitlement_defaults, :admin, :boolean, default: false
    add_column :entitlements, :admin, :boolean, null: true, default: nil
  end
end
