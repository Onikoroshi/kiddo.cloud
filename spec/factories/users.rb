FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@betheltv.com" }
    password "password"
    confirmed_at 1.day.ago
  end
end
