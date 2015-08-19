require 'rails_helper'

describe CancelProfile do
  describe '#perform' do
    context 'when the profile is already cancelled' do
      it "doesn't try to re-cancel the account" do
        profile = create(:profile, :cancelled)

        CancelProfile.perform(profile: profile, reason: '')

        expect(profile.first_name).not_to eq('CANCELLED')
      end
    end

    it 'sets the profile.cancelled to true' do
      profile = create(:user).profile

      CancelProfile.perform(profile: profile, reason: '')

      expect(profile).to be_cancelled
    end

    it 'removes the profile picture' do
      profile = build(:profile, :with_profile_picture)
      create(:user, profile: profile)

      CancelProfile.perform(profile: profile, reason: '')

      expect(profile.profile_picture).not_to be_present
    end

    it 'changes the users name to CANCELLED ACCOUNT' do
      profile = build(:profile)
      create(:user, profile: profile)
      first_name = "CANCELLED"
      last_name = "ACCOUNT"

      CancelProfile.perform(profile: profile, reason: '')

      expect(profile.first_name).to eq(first_name)
      expect(profile.last_name).to eq(last_name)
    end

    it 'prepends "cancelled" to the profile users email' do
      user = create(:user)
      profile = user.profile
      cancelled_email = "cancelled#{user.email}"

      CancelProfile.perform(profile: profile, reason: '')
      user.reload

      expect(user.email).to eq(cancelled_email)
    end

    it 'sets the reason for canceling' do
      user = create(:user)
      profile = user.profile
      cancel_reason = 'Too many emails'

      CancelProfile.perform(profile: profile, reason: cancel_reason)

      expect(profile.cancel_reason).to eq(cancel_reason)
    end
  end
end
