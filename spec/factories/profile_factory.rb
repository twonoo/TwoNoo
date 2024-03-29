include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :profile do
    first_name 'Joe'
    last_name 'Twooner'

    trait :with_profile_picture do
      profile_picture { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'blank.png'), 'image/png') }
    end

    trait :closed do
      closed_at { Time.current }
      closed_reason 'I have multiple accounts'
    end
  end
end
