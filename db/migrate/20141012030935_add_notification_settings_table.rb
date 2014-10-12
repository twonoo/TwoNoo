class AddNotificationSettingsTable < ActiveRecord::Migration
  def change
	create_table :notification_settings do |t|
		t.belongs_to :profile
		t.boolean :new_follower
		t.boolean :new_message
		t.boolean :new_rsvp
		t.boolean :new_following_activity
		t.boolean :attending_activity_update
		t.boolean :comment_on_owned_activity
		t.boolean :comment_on_attending_activity
		t.boolean :weekly_summary

		t.timestamps
	end
  end
end
