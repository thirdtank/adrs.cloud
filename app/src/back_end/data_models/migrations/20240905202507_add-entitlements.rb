Sequel.migration do
  up do
    create_table :entitlement_defaults do
      primary_key :id
      column :external_id, :citext, null: false, unique: true
      column :internal_name, :text, null: false, unique: true
      column :max_non_rejected_adrs, :integer, null: false
      column :created_at, :timestamptz, null: false
    end
    run (%{
COMMENT ON TABLE entitlement_defaults IS
  'Each row represents a collection of default values of entitles, for example, a "plan" for new users. It serves as default values that can be changed for everyone, e.g. make the plus plan allow 200 ADRs, however account-by-account values can be overridden by the entitlements table'
         })
    create_table :entitlements do
      primary_key :id
      foreign_key :entitlement_default_id, :entitlement_defaults, null: false, index: true
      foreign_key :account_id, :accounts, null: false, index: { unique: true }
      column :max_non_rejected_adrs, :integer, null: true
      column :created_at, :timestamptz, null: false
    end
    run(%{
COMMENT ON TABLE entitlements IS
  'Per-account entitlements that are intended to override the entitlement default. This allows an account to be on a specific plan, but have some entitlements changed'
         })
    alter_table :accounts do
      add_column :deactivated_at, :timestamptz, null: true
    end
  end
end
