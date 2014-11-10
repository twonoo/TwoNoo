class ChangeNotificationSettingsColumnsFromBooleanToInteger < ActiveRecord::Migration
  def change
    change_column :notification_settings, :new_follower, :integer
    change_column :notification_settings, :new_message, :integer
    change_column :notification_settings, :new_rsvp, :integer
    change_column :notification_settings, :new_following_activity, :integer
    change_column :notification_settings, :attending_activity_update, :integer
    change_column :notification_settings, :comment_on_owned_activity, :integer
    change_column :notification_settings, :comment_on_attending_activity, :integer
  end
end
