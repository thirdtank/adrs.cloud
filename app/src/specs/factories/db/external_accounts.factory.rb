FactoryBot.define do
  factory :external_account, class: "DB::ExternalAccount" do
    account
    sequence(:provider) { |n| Faker::Lorem.words.join(" ") + " #{n}" }
    external_account_id { SecureRandom.uuid }
    created_at { Time.now }
  end
end
