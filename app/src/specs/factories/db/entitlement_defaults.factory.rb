FactoryBot.define do
  factory :entitlement_default, class: "DB::EntitlementDefault" do
    sequence(:internal_name) { |n| "#{Faker::Subscription.plan} - #{n}" }
    max_non_rejected_adrs { rand(10) + 3 }
    max_projects { rand(10) + 3 }
  end
end
