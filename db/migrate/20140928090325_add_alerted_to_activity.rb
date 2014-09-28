class AddAlertedToActivity < ActiveRecord::Migration
  def change
	add_column :activities, :alerted, :boolean, default: false
  end
end
