Sequel.migration do
  up do
    create_table :adrs do
      primary_key :id
      column :external_id, :citext, null: false, unique: true
      column :title, :text, null: false
      column :context, :text, null: true
      column :facing, :text, null: true
      column :decision, :text, null: true
      column :neglected, :text, null: true
      column :achieve, :text, null: true
      column :accepting, :text, null: true
      column :because, :text, null: true
      column :accepted_at, :timestamptz, null: true
      column :created_at, :timestamptz, null: false
      foreign_key :account_id, :accounts, null: false, index: true
      constraint(:accepted_adr_requires_fields,Sequel.lit(%{
        (accepted_at IS NULL) OR
        (
          accepted_at  IS NOT NULL AND
          context      IS NOT NULL AND
          facing       IS NOT NULL AND
          decision     IS NOT NULL AND
          neglected    IS NOT NULL AND
          achieve      IS NOT NULL AND
          accepting    IS NOT NULL AND
          because      IS NOT NULL
        )
      }))
    end
    run %{
      COMMENT ON TABLE adrs IS
        'Architecture Decision Records'
    }
  end
end
