class AddRequireRsvpToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :rsvp, :boolean
  end
end
