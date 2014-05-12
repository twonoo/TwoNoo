class AddDescriptionToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :Description, :string
  end
end
