FactoryGirl.define do
  factory :time_entry do
    time Time.zone.now
    record_type nil
    time_recordable_id nil
    time_recordable_type nil
  end
end
