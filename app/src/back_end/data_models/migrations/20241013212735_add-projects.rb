Sequel.migration do
  up do
    create_table :projects do
      primary_key :id
      column :external_id, :citext, null: false, unique: true
      column :name, :text, null: false
      column :description, :text, null: true
      column :adrs_shared_by_default, :boolean, null: false
      foreign_key :account_id, :accounts, null: false, index: true
      column :archived_at, :timestamptz, null: true
      column :created_at, :timestamptz, null: false
      index [ :account_id, :name ], unique: true
    end
    run(%{
COMMENT ON TABLE projects IS
  'A way to group ADRs to avoid confusion or excessive tagging'
        })
    alter_table :adrs do
      add_foreign_key :project_id, :projects, null: false
    end
    alter_table :entitlement_defaults do
      add_column :max_projects, :integer, null: false, default: 10
    end
    alter_table :entitlements do
      add_column :max_projects, :integer, null: true
    end
  end
end
