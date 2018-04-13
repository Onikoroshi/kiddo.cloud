FactoryGirl.define do
  factory :enrollment_change do
    account nil
    enrollment nil
    requires_refund false
    requires_charge false
    changes ""
  end
end
