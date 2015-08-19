class ProfileController < ApplicationController

  before_filter :authenticate_user!, :except => [:show]

  def index
  end

  def edit
    @user = User.find(current_user)
    @suggested_city_search_terms = US_CITIES
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
        redirect_to new_user_session_path, notice: "Your password has been successfully changed. Please login again with the new password."
      end
    else
      redirect_to profile_change_password_path, alert: "Your current password is incorrect"
    end
  end

  def update
    user = User.find(params[:id])
    user.update(profile_params)
    if params[:location]
      location_updated = user.profile.update_location(params[:location], params[:neighborhood])
    end
    if user.save
      if location_updated == false
        redirect_to profile_edit_path, error: 'Invalid location'
      else
        redirect_to profile_edit_path, notice: 'Your profile has been updated'
      end
    end
  end

  def notification_setting
    if current_user.profile.notification_setting.nil?
      @notification_setting = NotificationSetting.new
      @notification_setting.profile_id = current_user.profile.id
      @notification_setting.save
    else
      @notification_setting = NotificationSetting.find(current_user.profile.notification_setting.id)
    end
  end

  def update_notification_setting
    @notification_setting = NotificationSetting.find(current_user.profile.notification_setting.id)
    @notification_setting.update(notification_setting_params)
    if @notification_setting.save
      redirect_to notification_setting_path, notice: "Your notification settings have been updated"
    end
  end

  def notifications
  end

  def privacy
  end

  def show
    @profile = User.find_by_id(params[:id])
    if @profile.nil? || @profile.profile.closed?
      redirect_to root_url
    end

    if current_user.present? && (params[:id] == current_user.id.to_s)
      @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).order('datetime ASC')
      @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).order('datetime DESC')
    else
      @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).
          where('cancelled = false').
          order('datetime ASC')

      @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).
          where('cancelled = false').
          order('datetime DESC')
    end
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

  def notification_setting_params
    params.require(:notification_setting).permit(:new_follower, :new_message, :new_rsvp, :new_following_activity,
                                                 :attending_activity_update, :comment_on_owned_activity, :comment_on_attending_activity, :activity_summary,
                                                 :activity_reminder, :local_activity_summary)
  end

  def activities_profile
    @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).order('datetime ASC')
    @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).order('datetime DESC')
    respond_to do |format|
      format.js
    end
  end

  def attending_profile
    @rsvps = Rsvp.where(user_id: params[:id])
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

  def people_profile
    @people = User.find(params[:id]).recommended_followers
    respond_to do |format|
      format.js
    end
  end

  def close
    profile = current_user.profile
    ProfileCloser.perform(profile: profile,
                          reason: closing_profile_params[:closed_reason])

    sign_out(profile.user)

    redirect_to root_url
  end

  private

  def closing_profile_params
    params.require(:profile).permit(:closed_reason)
  end
end
