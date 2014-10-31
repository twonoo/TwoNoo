namespace :summaries do
	task :new_followers => :environment do

    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('new_follower = ?', 1).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      new_followers = User.joins(:follow_relationships).where('followed_id = ?', id).where('follow_relationships.created_at > ?', Time.now - 1.day)

      if new_followers.present?
        user = User.find(user_id)

        
        puts "processing follower summary for #{user.name}"

        new_followers.each do |follower|
          puts "#{follower.name} is now follow you!"
        end

        #UserMailer.delay.new_followers(followed, followers)
        puts "#{user.email} was notified about followers"
			end
		end
	end
end
