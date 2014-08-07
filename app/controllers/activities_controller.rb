class ActivitiesController < ApplicationController
  before_filter :authenticate_user!

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
    @activity = Activity.new activity_name: params[:activity_name]
  end

  def edit
    @activity = Activity.find(params[:id])
    #@activity.datetime = @activity.datetime.strftime('%m/%d/%Y %I:%M %p')
  end

  def update
    activity = Activity.find(params[:id])
    params = activity_params
    activity.activity_type_ids=params[:activity_type_ids]
    params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    activity.update!(params)
    redirect_to activity
  end

  def create
    params = activity_params
    params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    @activity = Activity.create(params)
    @activity.user_id = current_user.id
    if @activity.save
      redirect_to @activity
    else
    end
  end

  def rsvp
  end

  private

  def activity_params
    params.require(:activity).permit(:activity_name, :location_name, :street_address_1, :street_address_2, :city, :state, :website, :description, :datetime, :rsvp, :image, activity_type_ids: [])
  end
end
