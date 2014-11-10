namespace :summaries do
	task :new_attending_activity_updates_daily => :environment do
    attending_activity_update_summary(2, 1.day)
	end
  
	task :new_attending_activity_updates_weekly => :environment do
    attending_activity_update_summary(3, 7.day)
	end

	task :new_comments_on_attending_activities_daily => :environment do
    new_comments_on_attending_activity_summary(2, 1.day)
	end
  
	task :new_comments_on_attending_activities_weekly => :environment do
    new_comments_on_attending_activity_summary(3, 7.day)
	end

	task :new_comments_on_owned_activities_daily => :environment do
    new_comments_on_owned_activity_summary(2, 1.day)
	end
  
	task :new_comments_on_owned_activities_weekly => :environment do
    new_comments_on_owned_activity_summary(3, 7.day)
	end

	task :new_followers_daily => :environment do
    follower_summary(2, 1.day)
	end
  
	task :new_followers_weekly => :environment do
    follower_summary(3, 7.day)
	end

	task :new_following_activities_daily => :environment do
    new_following_activities_summary(2, 1.day)
	end
  
	task :new_following_activities_weekly => :environment do
    new_following_activities_summary(3, 7.day)
	end

	task :new_messages_daily => :environment do
    new_messages_summary(2, 1.day)
	end
  
	task :new_messages_weekly => :environment do
    new_messages_summary(3, 7.day)
	end

	task :new_rsvps_daily => :environment do
    new_rsvps_summary(2, 1.day)
	end
  
	task :new_rsvps_weekly => :environment do
    new_rsvps_summary(3, 7.day)
	end

  task :recommended_followers => :environment do
    # Get a unique list of people that have recommended followers
    users_ids = RecommendedFollower.where('recommended_at is null').distinct.pluck('user_id')

    users_ids.each do |user_id|
      puts "processing recommendations for user #{user_id}"  
      
      # for each unique user get their top 3 recommended followers
      recommended_followers = RecommendedFollower.where('user_id = ?', user_id).limit(3)

      html = ''
      recommended_followers.each do |recommended_follower|
        puts "processing recommended follower #{recommended_follower.recommended_follower_id}"
        # verify they are not already following each other

        follow_relationship = FollowRelationship.where('follower_id = ?', user_id).where('followed_id = ?', recommended_follower.recommended_follower_id).first

        if follow_relationship.nil?
          puts "recommending #{recommended_follower.recommended_follower_id} follows #{user_id}"

          # get the user
          recommended_user = User.find_by_id(recommended_follower.recommended_follower_id)

          unless recommended_user.nil?
            # for each recommended follower generate a table row with the user profile icon and name
            html = html + "<tr><td>#{profile_img_small(recommended_user)}</td><td><a href=\"https://www.twonoo.com/profile/#{recommended_user.id}\">#{recommended_user.name}</a></td><td><a href=\"https://www.twonoo.com/users/follow/#{recommended_user.id}\" style='display: inline; padding: .2em .6em .3em; font-size: 75%; font-weight: bold; line-height: 1; color: #fff; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: .25em; background-color: #5bc0de;'>Follow</a></td></tr>"

            recommended_follower.recommended_at = Time.now
            recommended_follower.save
          else
            puts "user doesn't exist"
          end

        else
          puts "#{user_id} is already following #{recommended_follower.recommended_follower_id}"
        end

      end

      unless html.length == 0
        # send e-mail
        puts "html: " + html

        # Mandrill integration
        user = User.find_by_id(user_id)

        unless user.nil?
          #mandrill_to = [{:email => 'skeefe15@gmail.com', :type => 'to'}]
          mandrill_to = [{:email => user.email, :type => 'to'}]
          m = Mandrill::API.new
          t = 'recommended_followers'
          tc = [{"name" => "inviter", "content" => "TwoNoo Testerino"}]
          message = {  
           :to=>mandrill_to,  
           :merge_language=>"mailchimp",
           :global_merge_vars=>[
            {"name"=>"HTML", "content"=>html},
            ] 
          }  

          sending = m.messages.send_template t, tc, message  
          puts sending

          puts "sent email"

          # update the following recommendations that they were sent
          puts "updated that they were sent the recommendations"
        else
          puts "user doesn't exist"
        end
      else
        puts 'no html'
      end

    end
  end

  def attending_activity_update_summary(config_setting, time_period)
    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('attending_activity_update = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      # select the activities where the user is rsvp'd
      updated_activities = Activity.joins(:rsvps).where('rsvps.user_id = ?', user_id).where('activities.updated_at > ?', Time.now - time_period).
        where("activities.user_id != ?", user_id)

      if updated_activities.present?
        user = User.find(user_id)

        puts "processing activity update summary for #{user.name}"

        html = ''
        updated_activities.each do |activity|
          puts "#{activity.activity_name} has been updated!"

          # for each recommended follower generate a table row with the activity image and name
          html = html + "<tr><td>#{activity_img(activity)}</td><td><a href=\"https://www.twonoo.com/activity/#{activity.id}\">#{activity.activity_name}</a></td><td>"
          html = html + activity.description[0...149]
          html = html + "</td></tr>"

        end

        send_mandrill_table_email('attending_activity_update_summary', user.email, html)

      end
		end
  end

  def follower_summary(config_setting, time_period)
    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('new_follower = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      new_followers = User.joins(:follow_relationships).where('followed_id = ?', id).where('follow_relationships.created_at > ?', Time.now - time_period)

      if new_followers.present?
        user = User.find(user_id)

        
        puts "processing follower summary for #{user.name}"

        html = ''
        new_followers.each do |follower|
          puts "#{follower.name} is now following you!"


          # for each recommended follower generate a table row with the user profile icon and name
          html = html + "<tr><td>#{profile_img_small(follower)}</td><td><a href=\"https://www.twonoo.com/profile/#{follower.id}\">#{follower.name}</a></td><td>"
          
          # check to see if the followee is following the follower?
          unless follower.followers.include?(user)
            html = html + "<a href=\"https://www.twonoo.com/users/follow/#{follower.id}\" style='display: inline; padding: .2em .6em .3em; font-size: 75%; font-weight: bold; line-height: 1; color: #fff; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: .25em; background-color: #5bc0de;'>Follow</a>"
          end

          html = html + "</td></tr>"

        end

        send_mandrill_table_email('new_follower_summary', user.email, html)

      end
		end
  end

  def new_comments_on_attending_activity_summary(config_setting, time_period)
    # Get the people that want to be informed either daily or weekly
    profile_ids = NotificationSetting.where('comment_on_attending_activity = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      # select the activities where the user is rsvp'd
      commented_on_activities = Activity.joins(:rsvps).joins(:comments).where('rsvps.user_id = ?', user_id).where('comments.created_at > ?', Time.now - time_period)

      if commented_on_activities.present?
        user = User.find(user_id)

        puts "processing comments on activity for #{user.name}"

        html = ''
        commented_on_activities.each do |activity|
          # skip the activity if they are the owner
          next if activity.user_id == user_id

          puts "#{activity.activity_name} has been commented on!"

          # for each activity that was commented on follower generate a table row with the activity image and name
          html = html + "<tr><td>#{activity_img(activity)}</td><td><a href=\"https://www.twonoo.com/activity/#{activity.id}\">#{activity.activity_name}</a></td><td>"

          html = html + "<table>"
          activity.comments.where('created_at > ?', Time.now - time_period).each do |comment|
            html = html + "<tr><td>"
            if comment.user.nil? then
              html = html + "<b>Anonymous:</b>"
            else
              html = html + "<b>#{comment.user.profile.first_name}:</b>"
            end

            html = html + "<font size=\"1\">(#{comment.created_at.strftime("%m/%d/%y %l:%M %P")})</font>"
            html = html + "</td>"

            html = html + "<td>#{comment.comment}</td>"
            html = html + "</tr>"
          end

          html = html + "</table>"
          html = html + "</td></tr>"

        end

        send_mandrill_table_email('new_comments_on_attending_activity_summary', user.email, html)

      end
		end
  end

  def new_comments_on_owned_activity_summary(config_setting, time_period)
    # Get the people that want to be informed either daily or weekly
    profile_ids = NotificationSetting.where('comment_on_owned_activity = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      # select the activities where the user is rsvp'd
      commented_on_activities = Activity.joins(:comments).where('activities.user_id = ?', user_id).where('comments.created_at > ?', Time.now - time_period)

      if commented_on_activities.present?
        user = User.find(user_id)

        puts "processing comments on activity for #{user.name}"

        html = ''
        commented_on_activities.each do |activity|
          # skip the activity if they are the owner
          next if activity.user_id == user_id

          puts "#{activity.activity_name} has been commented on!"

          # for each activity that was commented on follower generate a table row with the activity image and name
          html = html + "<tr><td>#{activity_img(activity)}</td><td><a href=\"https://www.twonoo.com/activity/#{activity.id}\">#{activity.activity_name}</a></td><td>"

          html = html + "<table>"
          activity.comments.where('created_at > ?', Time.now - time_period).each do |comment|
            html = html + "<tr><td>"
            if comment.user.nil? then
              html = html + "<b>Anonymous:</b>"
            else
              html = html + "<b>#{comment.user.profile.first_name}:</b>"
            end

            html = html + "<font size=\"1\">(#{comment.created_at.strftime("%m/%d/%y %l:%M %P")})</font>"
            html = html + "</td>"

            html = html + "<td>#{comment.comment}</td>"
            html = html + "</tr>"
          end

          html = html + "</table>"
          html = html + "</td></tr>"

        end

        send_mandrill_table_email('new_comments_on_owned_activity_summary', user.email, html)

      end
		end
  end

  def new_following_activities_summary(config_setting, time_period)
    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('new_following_activity = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      # Get the users this one if following
      followed_users = FollowRelationship.where('follower_id = ?', user_id).pluck("followed_id")
      new_activities = Activity.where('user_id in (?)', followed_users).where('activities.created_at > ?', Time.now - time_period)

      if new_activities.present?
        user = User.find(user_id)

        
        puts "processing new activities for #{user.name}"

        html = ''
        new_activities.each do |activity|
          puts "#{activity.activity_name} has been created!"
          organizer = User.find(activity.user_id)

          # for each recommended follower generate a table row with the activity image and name
          html = html + "<tr>"
          html = html + "<td>#{profile_img_small(organizer)}</td><td><a href=\"https://www.twonoo.com/profile/#{organizer.id}\">#{organizer.name}</a></td>"
          html = html + "<td>#{activity_img(activity)}</td><td><a href=\"https://www.twonoo.com/activity/#{activity.id}\">#{activity.activity_name}</a></td>"
          html = html + "<td>#{activity.description[0...149]}</td>"
          html = html + "</tr>"

        end

        send_mandrill_table_email('new_following_activities_summary', user.email, html)

      end
		end
  end

  def new_messages_summary(config_setting, time_period)
    # Get the people that want to be informed either daily or weekly
    profile_ids = NotificationSetting.where('new_message = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      user = User.find(user_id)
      conversations = user.mailbox.inbox({:read => false})

      if conversations.present?

        puts "processing messages for #{user.name}"

        html = ''
        conversations.each do |conversation|
          messages = conversation.messages({:read => false})
          messages.each do |message|
            if (message.sender.id != user.id) && message.is_unread?(user)
              html = html + "<tr><td><a href='https://www.twonoo.com/converstation/#{conversation.id}'>"
              html = html + "<b>#{message.sender.profile.first_name}:</b> #{message.body}"

              html = html + "</a></td></tr>"
            end
          end
        end

        send_mandrill_table_email('new_messages_summary', user.email, html)

      end
		end
  end

  def new_rsvps_summary(config_setting, time_period)
    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('new_rsvp = ?', config_setting).pluck('profile_id')

    profile_ids.each do |id|
      user_id = Profile.where('id = ?', id).pluck('user_id').first
      puts "user_id: #{user_id}"

      # select the activities where the user is rsvp'd
      activities = Activity.where("user_id = ?", user_id).pluck("id")
      new_rsvps = Rsvp.where('activity_id in (?)', activities).where('created_at > ?', Time.now - time_period).where("user_id != ?", user_id)

      if new_rsvps.present?
        user = User.find(user_id)

        puts "processing activity update summary for #{user.name}"

        html = ''
        new_rsvps.each do |rsvp|
          rsvp_user = User.find(rsvp.user_id)
          activity = Activity.find(rsvp.activity_id)

          puts "#{rsvp_user.name} is coming!"

          # for each recommended follower generate a table row with the activity image and name
          html = html + "<tr>"
          html = html + "<td>#{profile_img_small(rsvp_user)}</td><td><a href=\"https://www.twonoo.com/profile/#{rsvp_user.id}\">#{rsvp_user.name}</a></td>"
          html = html + "<td>is going to: #{activity_img(activity)}</td><td><a href=\"https://www.twonoo.com/activity/#{activity.id}\">#{activity.activity_name}</a></td>"
          html = html + "</tr>"

        end

        send_mandrill_table_email('new_rsvps_summary', user.email, html)

      end
		end
  end

  def activity_img(activity)
    if activity.image.exists?
      "<img src='https://www.twonoo.com#{activity.image.url}' style=\"-moz-border-radius: 150px/150px; -webkit-border-radius: 150px 150px; border-radius: 150px/150px; border:solid 0px #FFF; width:30px;\"></img>".html_safe
    else
      "<span style='padding:5px 9px 5px 9px; background-color:#4DBFF5; font-size:20px; color:#FFFFFF; line-height:150px; -moz-border-radius: 150px/150px; -webkit-border-radius: 150px 150px; border-radius: 150px/150px; border:solid 1px #FFF; width:100px; margin:10px;'>#{activity.activity_name[0]}</span>".html_safe
    end
  end

  def profile_img_small(user)
    if user.profile.profile_picture_file_name
      "<img src='https://www.twonoo.com#{user.profile.profile_picture.url(:thumb)}' style=\"-moz-border-radius: 50px/50px; -webkit-border-radius: 50px 50px; border-radius: 50px/50px; border:solid 0px #FFF; width:30px;\"></img>".html_safe
    else
      "<span style='padding:5px 9px 5px 9px; background-color:#4DBFF5; font-size:20px; color:#FFFFFF; line-height:50px; -moz-border-radius: 50px/50px; -webkit-border-radius: 50px 50px; border-radius: 50px/50px; border:solid 1px #FFF; width:100px; margin:10px;'>#{user.profile.first_name[0] + user.profile.last_name[0]}</span>".html_safe
    end
  end

  def send_mandrill_table_email(template, email, html)
    unless html.length == 0
      # send e-mail
      puts "html: " + html

      # Mandrill integration
      mandrill_to = [{:email => email, :type => 'to'}]
      m = Mandrill::API.new
      t = template
      tc = [{"name" => "twonoo", "content" => "TwoNoo"}]
      message = {  
       :to=>mandrill_to,  
       :merge_language=>"mailchimp",
       :global_merge_vars=>[
        {"name"=>"USER_EMAIL", "content"=>email},
        {"name"=>"HTML", "content"=>html}
        ] 
      }  

      sending = m.messages.send_template t, tc, message  
      puts sending

      puts "sent email"
    else
      puts 'no html'
    end
  end end
