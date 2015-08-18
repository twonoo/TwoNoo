class CancelProfile
  def initialize(profile)
    @profile = profile
  end

  def self.perform(profile)
    new(profile).perform
  end

  def perform
    profile.tap do |p|
      p.update(cancelled: true)
      p.profile_picture.clear
    end
  end

  private

  attr_reader :profile
end
