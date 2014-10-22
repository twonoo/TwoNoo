class ActivitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :search, :show]

  def attending
    @rsvps = Rsvp.where(user_id: params[:id])
  end

  def index
  end

  def search
    
  end

  def user
    @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).order('datetime ASC')
    @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).order('datetime DESC')
  end

  def show
    @activity = Activity.find_by_id(params[:id])

    if @activity.nil?
      redirect_to root_url
      return
    end

    @organizer = User.find(@activity.user_id)
  end

  def new
    if     (Transaction.get_balance(current_user) > 0) \
        || (current_user.profile.nonprofit == 1) \
        || (current_user.profile.ambassador == 1) \
    then
      @activity = Activity.new activity_name: params[:activity_name]
    else
      redirect_to credits_purchase_path, alert: "Looks like you are out of credits. In order to create an activity, please purchase more."
    end
  end

  def edit
    @activity = Activity.find(params[:id])
  end

  def invite_people
    @activity = Activity.find(params[:id])
    UserMailer.delay.activity_invite(current_user, @activity, params[:emails])
  end


  def update
    @activity = Activity.find(params[:id])
    params = activity_params
    @activity.activity_type_ids=params[:activity_type_ids]

    dt_invalid = false
    begin
      params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    rescue
      dt_invalid = true
      params[:datetime] = Time.now
    end

    @activity.update(params)

    if @activity.save
      # Get the rsvp'd users
      @rsvps = Rsvp.where(activity_id: @activity.id).all
      @rsvps.each do |rsvp|
        @user = User.find_by_id(rsvp.user_id)
        if !@user.nil?
          @user.notify("#{current_user.name} updated an activity", "#{current_user.name} has updated an activity you're going to: <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

          UserMailer.delay.attending_activity_update(@user, @activity)
        end
      end
      redirect_to @activity
    else
      render :edit
    end
  end

  def cancel
    @activity = Activity.find(params[:id])
    if @activity.cancelled
    	@activity.cancelled = false
    else
    	@activity.cancelled = true
    end

    if @activity.save
      # Get the rsvp'd users
      @rsvps = Rsvp.where(activity_id: @activity.id).all
      @rsvps.each do |rsvp|
        @user = User.find_by_id(rsvp.user_id)
        if !@user.nil?
          @user.notify("#{current_user.name} updated an activity", "#{current_user.name} has updated an activity you're going to: <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

          UserMailer.delay.attending_activity_update(@user, @activity)
        end
      end
      redirect_to @activity
    else
      if dt_invalid
        @activity.errors.add(:base, "#{activity_params[:datetime]} is not a valid date.  Please enter dates in the format mm/dd/yyyy HH:MM AM/PM")
        @activity.datetime = Time.now
      end
      render :edit
    end
  end

  def create
    params = activity_params
    dt_invalid = false
    begin
      params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    rescue
      dt_invalid = true
      params[:datetime] = Time.now
    end

    @activity = Activity.create(params)
    @activity.user_id = current_user.id

    if @activity.save
      # Charge the organizer
      Transaction.create!(transaction_type_id: 2, user_id: current_user.id, amount: 1, balance: ((current_user.profile.nonprofit == 1) || current_user.profile.ambassador == 1)?Transaction.get_balance(current_user):(Transaction.get_balance(current_user) - 1))

      # Have the organizer RSVP to their own activity
      rsvp = Rsvp.new(activity_id: @activity.id, user_id: current_user.id)
      rsvp.save

      # Notfiy all followers of this organizer that a new activity has been created.
      current_user.followers.each do |follower|
        UserMailer.delay.new_following_activity(follower, current_user, @activity)
        follower.notify("#{current_user.name} created a new activity", "#{current_user.name} has created a new activity:  <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
      end

      redirect_to @activity
    else
      if dt_invalid
        @activity.errors.add(:base, "#{activity_params[:datetime]} is not a valid date.  Please enter dates in the format mm/dd/yyyy HH:MM AM/PM")
        @activity.datetime = Time.now
      end
      render :new
    end
  end

  def rsvp
    rsvp = Rsvp.new(activity_id: params[:activity_id], user_id: params[:user_id])

    # Notfiy the creator that a new user is going
    @activity = Activity.find(params[:activity_id])
    @organizer = User.find(@activity.user_id)

    unless current_user = @organizer
      @organizer.notify("#{current_user.name} is coming!", "#{current_user.name} is attending your activity: <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
      
      UserMailer.delay.new_rsvp(@organizer, current_user, @activity)
    end

    if rsvp.save
      redirect_to activity_path(@activity), notice: "You're now going to #{@activity.activity_name}!"
    end
  end

  def unrsvp
    rsvp = Rsvp.where(activity_id: params[:activity_id], user_id: params[:user_id]).first
    rsvp.delete
    redirect_to request.referer
  end

  def comment
    @activity = Activity.find(params[:id])
    @comment = @activity.comments.create
    @comment.user = current_user
    @comment.comment = params[:comment]
    if @comment.save
      #Notify all users either organizeing or attending this activity that a comment was added
      # Get the rsvp'd users
      @rsvp_ids = Rsvp.uniq.where(activity_id: @activity.id).pluck(:user_id)
      @rsvp_ids.each do |rsvp_id|
        @user = User.find_by_id(rsvp_id)
        if !@user.nil? && @user != current_user
          @user.notify("#{current_user.name} updated an activity", "#{current_user.name} has updated an activity you're going to: <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

          UserMailer.delay.comment_on_attending_activity(@user, @activity, current_user, @comment.comment)
        end
      end

      @organizer = User.find(@activity.user_id)
      if current_user != @organizer
          UserMailer.delay.comment_on_owned_activity(@organizer, @activity, current_user, @comment.comment)
      end
	#Notify all users that have commented on this acctivity that a comment was added
    end

    redirect_to :back
  end

  private

  def activity_params
    params.require(:activity).permit(:activity_name, :location_name, :street_address_1, :street_address_2, :city, :state, :website, :description, :datetime, :rsvp, :image, activity_type_ids: [])
  end
end
