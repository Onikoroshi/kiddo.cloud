FactoryGirl.define do
  factory :child do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    grade_entering "1"
    birthdate Time.zone.today - 5.years
    djusd_lunch_id rand(10000..99999)
    additional_info nil
    gender "male"

    trait :with_time_entry do
      after(:create) do |child|
        create(:time_entry,
          time: Time.zone.now,
          record_type: "entry",
          time_recordable_type: "Child",
          time_recordable_id: child.id)
      end
    end
  end
end
