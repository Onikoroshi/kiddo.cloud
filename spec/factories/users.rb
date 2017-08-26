FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@betheltv.com" }
    password "password"
  end
end
