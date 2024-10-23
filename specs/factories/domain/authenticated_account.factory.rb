FactoryBot.define do
  factory :authenticated_account, class: "AuthenticatedAccount" do
    account factory: [ :account, :active ]

    trait :admin do
      account factory: [ :account, :active, :admin ]
    end

    skip_create

    initialize_with do
      new(account:)
    end
  end
end
