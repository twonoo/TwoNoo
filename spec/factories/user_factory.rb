FactoryGirl.define do
  factory :user do
    profile
    confirmed_at Date.today
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
  end
end
