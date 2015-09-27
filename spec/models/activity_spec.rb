require 'rails_helper'
require 'spec_helper'
require 'pry'

describe Activity do
  stub_geocode_with(city: 'Boston', state: 'MA', latitude: 42.3601, longitude: -71.0589)

  # it { should be_valid }

  it "should be valid" do
    activity = FactoryGirl.build(:activity)

    expect(activity).to be_valid
  end
end
