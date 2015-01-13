class UsersController < ApplicationController

	before_filter :authenticate_user!

  def follow!
    current_user.follow!(params[:id])

    followed_user = User.find(params[:id])

    # notify the user that they are being followed
    followed_user.notify("You have a new follower!", "<a href='#{profile_path(current_user)}'>#{current_user.name}</a>")

    if followed_user.profile.notification_setting.new_follower
      UserMailer.delay.new_follower(followed_user, current_user)
    end

    redirect_to profile_path(params[:id]), notice: "You're now following #{followed_user.name}"
  end

  def unfollow!
    current_user.unfollow!(params[:id])
    redirect_to request.referer
  end

  def connected
    logger.info "user is connected!"
  end

end
