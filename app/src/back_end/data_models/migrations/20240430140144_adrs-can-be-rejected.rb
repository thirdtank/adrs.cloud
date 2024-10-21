Sequel.migration do
  up do
    alter_table :adrs do
      add_column :rejected_at, :timestamptz, null: true
      add_constraint(:adrs_cannot_be_accepted_and_rejected, %{
  ( (accepted_at IS NOT NULL) AND (rejected_at IS     NULL) ) OR
  ( (accepted_at IS     NULL) AND (rejected_at IS NOT NULL) ) OR
  ( (accepted_at IS     NULL) AND (rejected_at IS     NULL) )
        }
      )
    end
  end
end
