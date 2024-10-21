Sequel.migration do
  up do
    create_table :external_accounts, comment: "data from external accounts used to authenticate the related account" do
      column :provider, :citext
      column :external_account_id, :text
      foreign_key :account_id, :accounts
      key [ :account_id, :provider ]
    end
  end
end
