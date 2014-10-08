class ProfileController < ApplicationController
  def index
  end

  def edit
    @user = User.find(current_user)
  end

  def password
    @user = User.find(current_user)
  end

  def update_password
    user = User.find(params[:id])
    if user.valid_password?(params[:user][:current_password])
      user.update(password_params)
      logger.info user.errors
      if user.save
        redirect_to new_user_session_path
      end
    else
      redirect_to profile_change_password_path, alert: "Your current password is incorrect"
    end
  end

  def update
    user = User.find(params[:id])
    user.update(profile_params)
    if user.save
      redirect_to profile_edit_path, notice: "Your profile has been updated"
    end
  end

  def notifications
  end

  def privacy
  end

  def show
    @profile = User.find(params[:id])
    @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).order('datetime ASC')
    @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).order('datetime DESC')
  end

  def followers
    @followers = User.find(params[:id]).followers
  end

  def following
    @following = User.find(params[:id]).followed_users
  end

  def password_params
    params.require(:user).permit(:password)
  end

  def profile_params
    params.require(:user).permit(:email, profile_attributes: [:first_name, :last_name, :gender, :about_me, :id, :profile_picture])
  end

  def activities_profile
    @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).order('datetime ASC')
    @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).order('datetime DESC')
    respond_to do |format|
      format.js
    end
  end

  def attending_profile
    @rsvps = Rsvp.where(user_id: current_user.id)
    respond_to do |format|
      format.js
    end
  end

  def followers_profile
    @followers = User.find(params[:id]).followers
    respond_to do |format|
      format.js
    end
  end

  def following_profile
    @following = following
    respond_to do |format|
      format.js
    end
  end

end
