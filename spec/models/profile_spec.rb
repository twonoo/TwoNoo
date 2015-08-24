require 'rails_helper'

describe Profile do
  describe 'self.terms' do
    it "doesn't return closed profiles" do
      closed_profile = create(:profile, :closed)
      user = create(:user)
      closed_user = create(:user, profile: closed_profile)
      interest = create(:interest)
      user.interests = [interest]
      closed_user.interests = [interest]

      profiles = Profile.terms(interest.name)

      expect(profiles).to match_array([user.profile])
    end
  end
end
