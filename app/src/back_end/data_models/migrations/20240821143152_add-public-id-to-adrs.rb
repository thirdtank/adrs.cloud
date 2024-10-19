Sequel.migration do
  up do
    alter_table :adrs do
      add_column :shareable_id, :text, null: true, index: { unique: true }
    end
  end
end
