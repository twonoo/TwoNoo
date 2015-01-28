class RecommendedFollower < ActiveRecord::Base
	belongs_to :user

	after_initialize :init

	def init
  end

  def follower_profile
    @profile ||= Profile.find_by_user_id(self.recommended_follower_id)
  end

end
