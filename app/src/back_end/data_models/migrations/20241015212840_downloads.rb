Sequel.migration do
  up do
    create_table :downloads, comment: "Stores data to download when an account has made such a request", external_id: true do
      foreign_key :account_id, :accounts, index: { unique: true }
      column :all_data, :text, null: true
      column :data_ready_at, :timestamptz, null: true
      column :delete_at, :timestamptz, null: true
      constraint :download_ready,
        %{
  (all_data IS     NULL AND data_ready_at IS     NULL AND delete_at IS     NULL) OR
  (all_data IS NOT NULL AND data_ready_at IS NOT NULL AND delete_at IS NOT NULL)
        }
    end
  end
end
