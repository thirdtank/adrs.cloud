Sequel.migration do
  up do
    run %{CREATE EXTENSION IF NOT EXISTS citext}
    run %{
      CREATE DOMAIN email_address AS citext
        CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );
    }
    create_table :accounts do
      primary_key :id
      column :external_id, :citext, null: false, unique: true
      column :email, :email_address, null: false, unique: true
      column :created_at, :timestamptz, null: false
    end
    run %{
      COMMENT ON TABLE accounts IS
        'Stores individual user accounts, used for authentication'
    }
  end
end
