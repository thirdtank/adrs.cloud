FactoryBot.define do
  factory :adr, class: "DataModel::Adr" do
    account
    title { Faker::Book.unique.title }
    created_at { Time.now }
    trait :accepted do
      context   { Faker::Hipster.paragraph }
      facing    { Faker::Hipster.paragraph }
      decision  { Faker::Hipster.paragraph }
      neglected { Faker::Hipster.paragraph }
      achieve   { Faker::Hipster.paragraph }
      accepting { Faker::Hipster.paragraph }
      because   { Faker::Hipster.paragraph }

      accepted_at { Time.now }
    end
    trait :private do
      accepted

      shareable_id { nil }
    end
    trait :shared do
      accepted

      shareable_id { SecureRandom.uuid }
    end
  end
end
