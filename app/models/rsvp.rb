class Rsvp < ActiveRecord::Base

  belongs_to :user

	def self.user_rsvp?(activity_id, user_id)
		where("activity_id = ? AND user_id = ?", activity_id, user_id)
	end
end