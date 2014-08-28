class Rsvp < ActiveRecord::Base
	def self.user_rsvp?(activity_id, user_id)
		where("activity_id = ? AND user_id = ?", activity_id, user_id)
	end
end