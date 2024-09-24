FactoryBot.define do
  factory :entitlement, class: "DB::Entitlement" do
    max_non_rejected_adrs { [nil, rand(10) + 3].sample }
    entitlement_default
    association :account, :without_entitlement
  end
end
