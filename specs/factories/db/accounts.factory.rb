FactoryBot.define do
  factory :account, class: "DB::Account" do
    email { Faker::Internet.unique.email }

    transient do
      create_entitlement { true }
      create_project { true }
      make_admin { false }
    end

    trait :deactivated do
      deactivated_at { Time.now }
    end
    trait :active do
      deactivated_at { nil }
    end

    trait :admin do
      make_admin { true }
    end

    callback(:after_create) do |account, context|
      if context.create_entitlement
        create(:entitlement, account: account, max_non_rejected_adrs: 10, admin: context.make_admin)
      end
      if context.create_project
        create(:project, account: account)
      end
    end
    trait :without_entitlement do
      create_entitlement { false }
    end
  end
end
