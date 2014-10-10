class AddTzToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :tz, :string
  end
end
