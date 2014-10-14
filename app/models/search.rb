class Search < ActiveRecord::Base
	belongs_to :user


	after_initialize :init


	def init
	end

end
