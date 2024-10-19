Sequel.migration do
  up do
    create_table :downloads do
      primary_key :id
      foreign_key :account_id, :accounts, null: false, index: { unique: true }
      column :external_id, :citext, null: false, unique: true
      column :created_at, :timestamptz, null: false
      column :all_data, :text, null: true
      column :data_ready_at, :timestamptz, null: true
      column :delete_at, :timestamptz, null: true
      constraint :download_ready, Sequel.lit(
        %{
  (all_data IS     NULL AND data_ready_at IS     NULL AND delete_at IS     NULL) OR
  (all_data IS NOT NULL AND data_ready_at IS NOT NULL AND delete_at IS NOT NULL)
        })
    end
    run (%{
COMMENT ON TABLE downloads IS
  'Stores data to download when an account has made such a request'
         })
  end
end
