FactoryBot.define do
  factory :entitlement, class: "DataModel::Entitlement" do
    max_non_rejected_adrs { [nil, rand(10) + 3].sample }
    created_at { Time.now }
    entitlement_default
    association :account, :without_entitlement
  end
end
