Sequel.migration do
  up do
    create_table :entitlement_defaults, comment: "Each row represents a collection of default values of entitles, for example, a \"plan\" for new users. It serves as default values that can be changed for everyone, e.g. make the plus plan allow 200 ADRs, however account-by-account values can be overridden by the entitlements table", external_id: true do
      column :internal_name, :text, unique: true
      column :max_non_rejected_adrs, :integer
    end
    create_table :entitlements, comment: "Per-account entitlements that are intended to override the entitlement default. This allows an account to be on a specific plan, but have some entitlements changed" do
      foreign_key :entitlement_default_id, :entitlement_defaults
      foreign_key :account_id, :accounts, index: { unique: true }
      column :max_non_rejected_adrs, :integer, null: true
    end
    alter_table :accounts do
      add_column :deactivated_at, :timestamptz, null: true
    end
  end
end
