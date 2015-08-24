FactoryGirl.define do
  factory :user do
    profile
    confirmed_at Date.today
    fb_token 'token'
    fb_token_expires_in { 10.days }
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
  end
end
