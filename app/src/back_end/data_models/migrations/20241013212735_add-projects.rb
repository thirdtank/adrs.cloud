Sequel.migration do
  up do
    create_table :projects, comment: "A way to group ADRs to avoid confusion or excessive tagging", external_id: true do
      column :name, :text
      column :description, :text, null: true
      column :adrs_shared_by_default, :boolean
      foreign_key :account_id, :accounts
      column :archived_at, :timestamptz, null: true
      key [ :account_id, :name ]
    end
    alter_table :adrs do
      add_foreign_key :project_id, :projects
    end
    alter_table :entitlement_defaults do
      add_column :max_projects, :integer, default: 10
    end
    alter_table :entitlements do
      add_column :max_projects, :integer, null: true
    end
  end
end
