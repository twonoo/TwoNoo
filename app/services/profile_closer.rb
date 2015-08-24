class ProfileCloser
  def initialize(profile:, reason: '')
    @profile = profile
    @reason = reason
  end

  def self.perform(profile:, reason: '')
    new(profile: profile, reason: reason).perform
  end

  def perform
    if profile.closed?
      profile
    else
      profile.tap do |p|
        p.update(profile_attributes)
        p.profile_picture.clear
        user.skip_reconfirmation!
        user.update(user_attributes)
      end
    end
  end

  private

  attr_reader :profile, :reason

  def user
    @user ||= profile.user
  end

  def profile_attributes
    {
      closed: true,
      closed_reason: reason,
      first_name: 'CANCELLED',
      last_name: 'ACCOUNT'
    }
  end

  def user_attributes
    {
      email: "#{SecureRandom.hex(2)}cancelled#{profile.user.email}",
      fb_token: nil,
      fb_token_expires_in: nil,
      provider: nil,
      uid: nil,
      encrypted_password: SecureRandom.hex(20)
    }
  end
end
