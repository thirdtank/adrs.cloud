FactoryBot.define do
  factory :project, class: "DB::Project" do
    account
    sequence(:name) { |n| (Faker::Book.title + ", Part #{n}").gsub(/'/,"") }
    description {
      [ nil, Faker::Lorem.paragraph ].sample
    }
    adrs_shared_by_default { [ true, false ].sample }
    trait :archived do
      archived_at { Time.now }
    end
  end
end
