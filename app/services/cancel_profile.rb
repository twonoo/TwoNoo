class CancelProfile
  def initialize(profile)
    @profile = profile
  end

  def self.perform(profile)
    new(profile).perform
  end

  def perform
    close_profile
  end

  private

  attr_reader :profile

  def close_profile
    profile.update(cancelled: true)
  end
end
