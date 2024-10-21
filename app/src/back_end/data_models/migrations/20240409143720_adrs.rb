Sequel.migration do
  up do
    create_table :adrs, comment: "Architecture Decision Records", external_id: true do
      column :title, :text
      column :context, :text, null: true
      column :facing, :text, null: true
      column :decision, :text, null: true
      column :neglected, :text, null: true
      column :achieve, :text, null: true
      column :accepting, :text, null: true
      column :because, :text, null: true
      column :accepted_at, :timestamptz, null: true
      foreign_key :account_id, :accounts
      constraint(:accepted_adr_requires_fields,%{
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
      })
    end
  end
end
