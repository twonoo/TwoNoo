class AddRemindersAndActivitySummariesToNotificationSettings < ActiveRecord::Migration
  def change
    add_column :notification_settings, :activity_reminder, :integer, :default => 1
    add_column :notification_settings, :local_activity_summary, :integer, :default => 2
  end
end
