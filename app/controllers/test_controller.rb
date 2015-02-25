class TestController < ApplicationController

  def test_steve
    ActiveRecord::Base.connection.execute('TRUNCATE recommended_followers')

    other_users = User.all
    user = User.where(id: 2).first

    other_users.each do |other_user|

      follow_relationship = FollowRelationship.exists?(follower_id: user.id, followed_id: other_user.id)
      recommended_follow_relationship = RecommendedFollower.exists?(user_id: user.id, recommended_follower_id: other_user.id)

      if !follow_relationship && !recommended_follow_relationship && user.id != other_user.id

        user_followering = user.follow_relationships.pluck(:followed_id)
        other_user_following = other_user.follow_relationships.pluck(:followed_id)
        num_shared_followers = (user_followering & other_user_following).length

        are_friends = user.facebook_friends?(other_user)
        if are_friends
          other_user.recommend_follow!(user, 1)
        elsif user.profile.state == other_user.profile.state && num_shared_followers >= 3
          other_user.recommend_follow!(user, 2)
        elsif user.profile.state == other_user.profile.state && user.followers.where(id: other_user.id).exists?
          other_user.recommend_follow!(user, 3)
        end

      end
    end
  end

end
