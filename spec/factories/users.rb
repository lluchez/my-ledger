FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test-user#{n}@example.com" }
    name "marty"
    password "!Tmdk3k5n6"
    password_confirmation "!Tmdk3k5n6"
  end
end
