FactoryBot.define do
  factory :download, class: "DB::Download" do
    account

    trait :ready do
      all_data      { { some: "downloads" }.to_json }
      data_ready_at { Time.now }
      delete_at     { Time.now + (60 * 60 * 24) }
    end
  end
end
