FactoryBot.define do
  factory :account, class: "DataModel::Account" do
    email { Faker::Internet.unique.email }
    created_at { Time.now }
  end
end
