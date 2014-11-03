namespace :summaries do
	task :new_followers_daily => :environment do

    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('new_follower = ?', 2).pluck('profile_id')

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
  
	task :new_followers_weekly => :environment do

    # Get the people that want to be informed once a week
    profile_ids = NotificationSetting.where('new_follower = ?', 3).pluck('profile_id')

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

        follow_relationship = FollowRelationship.where('followed_id = ?', user_id).where('follower_id = ?', recommended_follower.recommended_follower_id).first

        if follow_relationship.nil?
          puts "recommending #{recommended_follower.recommended_follower_id} follows #{user_id}"

          # get the user
          recommended_user = User.find_by_id(recommended_follower.recommended_follower_id)

          unless recommended_user.nil?
            # for each recommended follower generate a table row with the user profile icon and name
            html = html + "<tr><td>#{profile_img_small(recommended_user)}</td><td><a href=\"https://wwww.twonoo.com/profile/#{recommended_user.id}\">#{recommended_user.name}</a></td></tr>"
          else
            puts "user doesn't exist"
          end

        else
          puts "#{follow_relationship.follower_id} is already following #{user_id}"
        end

      end

      unless html.length == 0
        # send e-mail
        puts "html: " + html

        # Mandrill integration
        user = User.find_by_id(user_id)

        unless user.nil?
          mandrill_to = [{:email => 'skeef15@gmail.com', :type => 'to'}]
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

  def profile_img_small(user)
    if user.profile.profile_picture_file_name
      "<img src='#{user.profile.profile_picture.url(:thumb)}' style=\"-moz-border-radius: 50px/50px; -webkit-border-radius: 50px 50px; border-radius: 50px/50px; border:solid 0px #FFF; width:30px;\"></img>".html_safe
    else
      "<span style='padding:5px 9px 5px 9px; background-color:#4DBFF5; font-size:20px; color:#FFFFFF; line-height:50px; -moz-border-radius: 50px/50px; -webkit-border-radius: 50px 50px; border-radius: 50px/50px; border:solid 1px #FFF; width:100px; margin:10px;'>#{user.profile.first_name[0] + user.profile.last_name[0]}</span>".html_safe
    end
  end
end
