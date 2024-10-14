FactoryBot.define do
  factory :project, class: "DB::Project" do
    account
    sequence(:name) { |n| (Faker::Book.title + ", Part #{n}").gsub(/'/,"") }
    description {
      [ nil, Faker::Lorem.paragraph ].sample
    }
  end
end
