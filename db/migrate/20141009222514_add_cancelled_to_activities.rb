class AddCancelledToActivities < ActiveRecord::Migration
  def change
	add_column :activities, :cancelled, :boolean, default: false
  end
end
