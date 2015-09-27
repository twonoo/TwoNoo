FactoryGirl.define do
  factory :activity do
    sequence(:activity_name) { |n| "Interest #{n}" }
    # sequence(:date) { |n| Date.current + n.days }
    # sequence(:time) { |n| Time.now + n.days }
    sequence(:datetime) { |n| DateTime.now + n.hours}
    city "Boston"
    state "MA"
    latitude 42.3601
    longitude -71.0589
    sequence(:description) { |n| "This is a test activity, number #{n}"}

    after(:build) do |activity, evaluator|
      activity.interests << FactoryGirl.build(:interest)
    end
  end
end
