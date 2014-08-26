class AddActivityIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :activity_id, :integer
  end
end
