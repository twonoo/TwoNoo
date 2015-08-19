class CancelProfile
  def initialize(profile)
    @profile = profile
  end

  def self.perform(profile)
    new(profile).perform
  end

  def perform
    profile.tap do |p|
      p.update(profile_attributes)
      p.profile_picture.clear
      user.skip_reconfirmation!
      user.update(email: "cancelled#{profile.user.email}")
    end
  end

  private

  attr_reader :profile

  def user
    @user ||= profile.user
  end

  def profile_attributes
    {
      cancelled: true,
      first_name: 'CANCELLED',
      last_name: 'ACCOUNT'
    }
  end
end
