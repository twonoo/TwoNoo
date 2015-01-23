namespace :followers do

  task :find_recommended => :environment do

    ActiveRecord::Base.connection.execute('TRUNCATE recommended_followers')

    other_users = User.all
    User.find_in_batches(batch_size: 500) do |batch|
      batch.each do |user|

        other_users.each do |other_user|
          puts "Processing #{user.email}(#{user.id}) with #{other_user.email}(#{other_user.id})"

          follow_relationship = FollowRelationship.exists?(follower_id: user.id, followed_id: other_user.id)

          if !follow_relationship && user.id != other_user.id

            users_being_followed = user.follow_relationships.pluck(:followed_id)
            users_following = other_user.follow_relationships.pluck(:followed_id)
            num_shared_followers = (users_being_followed & users_following).length

            are_friends = user.facebook_friends?(other_user)
            if are_friends
              other_user.recommend_follow!(user, 1)
              puts 'Result --> Facebook Friends: Priority 1'
            elsif user.profile.state == other_user.profile.state && num_shared_followers >= 3
              other_user.recommend_follow!(user, 2)
              puts 'Result --> Same State and more than 3 shared interests: Priority 2'
            elsif user.profile.state == other_user.profile.state && user.followers.where(id: other_user.id).exists?
              other_user.recommend_follow!(user, 3)
              puts 'Result --> Being followed but not following: Priority 3'
            else
              puts 'Result --> No shared interests: No record created'
            end

          end
        end

      end
    end

  end

end
