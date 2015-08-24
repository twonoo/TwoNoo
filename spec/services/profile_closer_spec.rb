require 'rails_helper'

describe ProfileCloser do
  describe '#perform' do
    context 'when the profile is already closed' do
      it "doesn't try to re-close the account" do
        profile = create(:profile, :closed)

        ProfileCloser.perform(profile: profile, reason: '')

        expect(profile.first_name).not_to eq('closed')
      end
    end

    it 'sets the profile.closed to true' do
      profile = create(:user).profile

      ProfileCloser.perform(profile: profile, reason: '')

      expect(profile).to be_closed
    end

    it 'removes the profile picture' do
      profile = build(:profile, :with_profile_picture)
      create(:user, profile: profile)

      ProfileCloser.perform(profile: profile, reason: '')

      expect(profile.profile_picture).not_to be_present
    end

    it 'changes the users name to CANCELLED ACCOUNT' do
      profile = build(:profile)
      create(:user, profile: profile)
      first_name = "CANCELLED"
      last_name = "ACCOUNT"

      ProfileCloser.perform(profile: profile, reason: '')

      expect(profile.first_name).to eq(first_name)
      expect(profile.last_name).to eq(last_name)
    end

    it 'prepends a random number and "cancelled" to the profile users email' do
      user = create(:user)
      profile = user.profile
      allow(SecureRandom).to receive(:hex).and_return('1234')
      closed_email = "1234cancelled#{user.email}"

      ProfileCloser.perform(profile: profile, reason: '')
      user.reload

      expect(user.email).to eq(closed_email)
    end

    it 'sets the reason for closing' do
      user = create(:user)
      profile = user.profile
      closed_reason = 'Too many emails'

      ProfileCloser.perform(profile: profile, reason: closed_reason)

      expect(profile.closed_reason).to eq(closed_reason)
    end

    it 'removes the facebook info from the user' do
      user = create(:user, :facebook)
      profile = user.profile

      ProfileCloser.perform(profile: profile)
      user.reload

      expect(user.fb_token).to be_nil
      expect(user.fb_token_expires_in).to be_nil
      expect(user.provider).to be_nil
      expect(user.uid).to be_nil
    end

    it 'sets the encrypted_password to a random string' do
      allow(BCrypt::Password).to receive(:create).and_return('1234')
      user = create(:user, encrypted_password: 'abcd')

      ProfileCloser.perform(profile: user.profile)
      user.reload

      expect(user.encrypted_password).to eq('1234')
    end
  end
end
