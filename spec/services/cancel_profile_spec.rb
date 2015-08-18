require 'rails_helper'

describe CancelProfile do
  describe '#perform' do
    it 'sets the profile.cancelled to true' do
      profile = build(:profile)

      CancelProfile.perform(profile)

      expect(profile).to be_cancelled
    end
  end
end
