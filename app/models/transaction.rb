class Transaction < ActiveRecord::Base
	belongs_to :transaction_type
	belongs_to :activity
	default_scope { includes(:transaction_type, :activity) }

	def self.get_balance(user)
		res = self.where(user_id: user.id).last
		if res.nil?
			return 0
		else
			res.balance
		end
	end

end