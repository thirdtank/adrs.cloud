FactoryBot.define do
  factory :entitlement_default, class: "DB::EntitlementDefault" do
    internal_name { "#{Faker::Subscription.plan} - #{SecureRandom.uuid}" }
    max_non_rejected_adrs { rand(10) + 3 }
    max_projects { rand(10) + 3 }
  end
end
