FactoryBot.define do
  factory :entitlement_default, class: "DataModel::EntitlementDefault" do
    internal_name { Faker::Subscription.unique.plan }
    max_non_rejected_adrs { rand(10) + 3 }
    created_at { Time.now }
  end
end
