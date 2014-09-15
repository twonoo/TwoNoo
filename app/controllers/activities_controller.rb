class ActivitiesController < ApplicationController
  before_filter :authenticate_user!

  def attending
    @rsvps = Rsvp.where(user_id: current_user.id)
  end

  def index
  end

  def search
    search_location = Geocoder.search(params[:location]).first.coordinates
    @activities = Activity.terms(params[:terms])
    @activities = @activities.joins(:activity_types).where('activity_types.id' => params[:type]) unless params[:type].blank?
    @activities = @activities.where('datetime BETWEEN ? AND ?', Date.yesterday, params[:when])
    @activities = @activities.within(params[:miles], origin: search_location)
  end

  def user
    @activities = Activity.where(user_id: params[:id])
  end

  def show
    @activity = Activity.find(params[:id])
    @organizer = User.find(@activity.user_id)
  end

  def new
    if Transaction.get_balance(current_user) > 0
      @activity = Activity.new activity_name: params[:activity_name]
    else
      redirect_to credits_purchase_path
    end
  end

  def edit
    @activity = Activity.find(params[:id])
  end

  def update
    activity = Activity.find(params[:id])
    params = activity_params
    activity.activity_type_ids=params[:activity_type_ids]
    params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    activity.update!(params)

    # Get the rsvp'd users
    @rsvps = Rsvp.where(activity_id: activity.id).all
    @rsvps.each do |rsvp|
      @user = User.find_by_id(rsvp.user_id)
      if !@user.nil? then
        @user.notify("#{current_user.name} updated an activity", "#{current_user.name} has updated an activity you're going to: <a href='http://twonoo.com:8000/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
      end
    end

    redirect_to activity
  end

  def create
    params = activity_params
    params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    @activity = Activity.create(params)
    @activity.user_id = current_user.id
    if @activity.save
      # Notfiy all followers of this organizer that a new activity has been created.
      current_user.followers.each do |follower|
        follower.notify("#{current_user.name} created a new activity", "#{current_user.name} has created a new activity:  <a href='http://twonoo.com:8000/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
      end
      Transaction.create!(transaction_type_id: 2, user_id: current_user.id, amount: 1, balance: (Transaction.get_balance(current_user) - 1))
      redirect_to @activity
    end
  end

  def rsvp
    rsvp = Rsvp.new(activity_id: params[:activity_id], user_id: params[:user_id])

    # Notfiy the creator that a new user is going
    @activity = Activity.find(params[:activity_id])
    @organizer = User.find(@activity.user_id)
    @organizer.notify("#{current_user.name} is coming!", "#{current_user.name} is attending your activity: <a href='http://twonoo.com:8000/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

    if rsvp.save
      redirect_to request.referer
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
    @comment.save

    redirect_to :back
  end

  private

  def activity_params
    params.require(:activity).permit(:activity_name, :location_name, :street_address_1, :street_address_2, :city, :state, :website, :description, :datetime, :rsvp, :image, activity_type_ids: [])
  end
end
