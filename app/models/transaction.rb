class Transaction < ActiveRecord::Base
	belongs_to :transaction_type
	belongs_to :activity
	default_scope { includes(:transaction_type, :activity) }

	def self.get_balance(user)
		if (user.profile.ambassador == 1) || (user.profile.nonprofit == 1)
			return 99
                else
			res = self.where(user_id: user.id).last
			if res.nil?
				return 0
			else
				res.balance
			end
		end
	end

end
