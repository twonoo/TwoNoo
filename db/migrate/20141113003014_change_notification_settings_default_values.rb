class ChangeNotificationSettingsDefaultValues < ActiveRecord::Migration
  def change
    change_column :notification_settings, :new_follower, :integer, :default => 2
    change_column :notification_settings, :new_message, :integer, :default => 1
    change_column :notification_settings, :new_rsvp, :integer, :default => 1
    change_column :notification_settings, :new_following_activity, :integer, :default => 2
    change_column :notification_settings, :attending_activity_update, :integer, :default => 1
    change_column :notification_settings, :comment_on_owned_activity, :integer, :default => 1
    change_column :notification_settings, :comment_on_attending_activity, :integer, :default => 1
    remove_column :notification_settings, :weekly_summary, :integer, :default => 1
    add_column :notification_settings, :activity_summary, :integer, :default => 3
  end
end
