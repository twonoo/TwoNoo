class NotificationSetting < ActiveRecord::Base
	belongs_to :profile

	after_initialize :init


	def init
	end

end
