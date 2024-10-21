Sequel.migration do
  up do
    run %{CREATE EXTENSION IF NOT EXISTS citext}
    run %{
      CREATE DOMAIN email_address AS citext
        CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );
    }
    create_table :accounts, comment: "Stores individual user accounts, used for authentication", external_id: true do
      column :email, :email_address, unique: true
    end
  end
end
