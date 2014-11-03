class RecommendedFollower < ActiveRecord::Base
	belongs_to :user

	after_initialize :init


	def init
	end

end
