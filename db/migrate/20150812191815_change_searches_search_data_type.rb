class ChangeSearchesSearchDataType < ActiveRecord::Migration
	def up
	  change_column :searches, :search, :text
	end

	def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :searches, :search, :string
	end
end
