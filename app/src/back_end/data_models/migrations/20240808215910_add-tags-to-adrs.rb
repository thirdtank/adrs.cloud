Sequel.migration do
  up do
    alter_table :adrs do
      add_column :tags, "text[]", null: false, default: Sequel.pg_array([],:text)
    end
  end
end
