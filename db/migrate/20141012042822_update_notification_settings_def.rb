class UpdateNotificationSettingsDef < ActiveRecord::Migration
  def change
	change_column "notification_settings", "new_follower", "boolean", {default: true}
	change_column "notification_settings", "new_message", "boolean", {default: true}
	change_column "notification_settings", "new_rsvp", "boolean", {default: true}
	change_column "notification_settings", "new_following_activity", "boolean", {default: true}
	change_column "notification_settings", "attending_activity_update", "boolean", {default: true}
	change_column "notification_settings", "comment_on_owned_activity", "boolean", {default: true}
	change_column "notification_settings", "comment_on_attending_activity", "boolean", {default: true}
	change_column "notification_settings", "weekly_summary", "boolean", {default: true}
  end
end
