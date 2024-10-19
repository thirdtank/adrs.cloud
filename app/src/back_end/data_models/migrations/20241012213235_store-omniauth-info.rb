Sequel.migration do
  up do
    create_table :external_accounts do
      primary_key :id
      column :provider, :citext, null: false
      column :external_account_id, :text, null: false
      foreign_key :account_id, :accounts, null: false, index: true
      column :created_at, :timestamptz, null: false
      index [ :account_id, :provider ], unique: true
    end
    run(%{
COMMENT ON TABLE external_accounts IS
  'data from external accounts used to authenticate the related account'
         })
  end
end
