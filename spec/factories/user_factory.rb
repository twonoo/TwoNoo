FactoryGirl.define do
  factory :user do
    profile
    confirmed_at Date.today
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
    password_confirmation 'password'

    trait :facebook do
      fb_token 'token'
      fb_token_expires_in { 10.days }
      provider 'facebook'
      sequence(:uid) { |n| "1234567#{n}" }
    end
  end
end
