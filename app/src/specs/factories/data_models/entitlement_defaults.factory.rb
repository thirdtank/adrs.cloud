FactoryBot.define do
  factory :entitlement_default, class: "DataModel::EntitlementDefault" do
    sequence(:internal_name) { |n| "#{Faker::Subscription.plan} - #{n}" }
    max_non_rejected_adrs { rand(10) + 3 }
    created_at { Time.now }
  end
end
