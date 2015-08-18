require 'rails_helper'

describe CancelProfile do
  describe '#perform' do
    it 'sets the profile.cancelled to true' do
      profile = build(:profile)

      CancelProfile.perform(profile)

      expect(profile).to be_cancelled
    end

    it 'removes the profile picture' do
      profile = build(:profile, :with_profile_picture)

      CancelProfile.perform(profile)

      expect(profile.profile_picture).not_to be_present
    end
  end
end
