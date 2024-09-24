FactoryBot.define do
  factory :authenticated_account, class: "AuthenticatedAccount" do
    account factory: [ :account, :active ]

    skip_create

    initialize_with do
      new(account:)
    end
  end
end
