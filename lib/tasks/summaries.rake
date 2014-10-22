namespace :summaries do
	task :new_followers => :environment do

    # Get the people that want to be informed once a week
    NotificationSetting.where("new_follower = 2").each do |p|
      followed = p.profile.user

      follow_relationships = FollowRelationship.where("followed_id = ?", followed.id).where("created_at < ?", Time.now - 1.day).pluck("follower_id")
      followers = User.where("id IN (?)", follow_relationships)

      if followers.present?
        #UserMailer.delay.new_followers(followed, followers)

        puts "#{followed.email} was notified about followers"
			end
		end
	end
end
