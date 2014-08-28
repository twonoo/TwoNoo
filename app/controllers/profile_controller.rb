class ProfileController < ApplicationController
  def index
  end

  def edit
    @user = User.find(current_user)
  end

  def update
    user = User.find(params[:id])
    user.update(profile_params)
    if user.save
      redirect_to user
    end
  end

  def notifications
  end

  def privacy
  end

  def show
    @profile = User.find(params[:id])
    @activities = Activity.where(user_id: params[:id])
  end

  def followers
    @followers = User.find(params[:id]).followers
  end

  def following
    @following = User.find(params[:id]).followed_users
  end

  def profile_params
    params.require(:user).permit(:email, profile_attributes: [:first_name, :last_name, :gender, :about_me, :id, :profile_picture])
  end
end
