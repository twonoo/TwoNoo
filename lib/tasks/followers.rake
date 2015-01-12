namespace :followers do

  task :find_recommended => :environment do

    ActiveRecord::Base.connection.execute('TRUNCATE recommended_followers')

    other_users = User.all
    User.find_in_batches(batch_size: 50) do |batch|
      batch.each do |user|
        other_users.each do |other_user|

          follow_relationship = FollowRelationship.exists?(follower_id: user.id, followed_id: other_user.id)
          recommended_follow_relationship = RecommendedFollower.exists?(user_id: user.id, recommended_follower_id: other_user.id)

          if !follow_relationship && !recommended_follow_relationship && user.id != other_user.id

            user_followering = user.follow_relationships.pluck(:followed_id)
            other_user_following = other_user.follow_relationships.pluck(:followed_id)
            num_shared_followers = (user_followering & other_user_following).length

            are_friends = user.facebook_friends?(other_user)
            if are_friends
              user.recommend_follow!(other_user, 1)
            elsif user.profile.state == other_user.profile.state && num_shared_followers >= 3
              user.recommend_follow!(other_user, 2)
            elsif User.first.followers.where(id: other_user.id).exists?
              user.recommend_follow!(other_user, 3)
            end

          else
          end
        end
      end

    end

  end

end
