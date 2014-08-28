class Transaction < ActiveRecord::Base
	belongs_to :transaction_type
	belongs_to :activity
	default_scope { includes(:transaction_type, :activity) }
end