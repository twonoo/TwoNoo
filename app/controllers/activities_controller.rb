class ActivitiesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :search, :show]

  def attending
    @rsvps = Rsvp.where(user_id: current_user.id)
  end

  def index
  end

  def search
    # Setup location constraints
    denver = [39.737567, -104.9847179]
    pittsburgh = [40.44062479999999, -79.9958864]

    # Convert search parameter to coordinates
    search_coordinates = Geocoder.search(params[:location]).first.coordinates
    unless Geocoder::Calculations.distance_between(search_coordinates, denver) < 100 || Geocoder::Calculations.distance_between(search_coordinates, pittsburgh) < 100
      redirect_to root_path, notice: "You're trying to search outside of the area"
    end

    # Determine date range
    if !params[:when].blank?
      case params[:when]
        when "Today"
          end_date = Date.today + 1
        when "This Week"
          end_date = Date.today.at_end_of_week + 1
        when "Next Two Weeks"
          end_date = 2.weeks.from_now + 1
        else
          end_date = 1.month.from_now + 1
      end
      from_date = Date.today
    else
      from_date = Time.strptime(params[:from_date], '%m/%d/%Y')
      end_date = Time.strptime(params[:to_date], '%m/%d/%Y')
    end

    # Build search query
    @activities = Activity.terms(params[:terms])
    @activities = @activities.joins(:activity_types).where('activity_types.id' => params[:type]) unless params[:type].blank?
    @activities = @activities.where('datetime BETWEEN ? AND ?', from_date, end_date)
    @activities = @activities.within(params[:distance], origin: search_coordinates).order('datetime ASC')
    
    render 'noresults' unless @activities.within(params[:distance], origin: search_coordinates).order('datetime ASC').present? 
  end

  def user
    @activities = Activity.where(user_id: params[:id]).where('datetime >= ?', Time.now).order('datetime ASC')
    @activitiesPast = Activity.where(user_id: params[:id]).where('datetime < ?', Time.now).order('datetime DESC')
  end

  def show
    @activity = Activity.find(params[:id])
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

  def update
    @activity = Activity.find(params[:id])
    params = activity_params
    @activity.activity_type_ids=params[:activity_type_ids]
    params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    @activity.update(params)

    if @activity.save
      # Get the rsvp'd users
      @rsvps = Rsvp.where(activity_id: @activity.id).all
      @rsvps.each do |rsvp|
        @user = User.find_by_id(rsvp.user_id)
        if !@user.nil?
          @user.notify("#{current_user.name} updated an activity", "#{current_user.name} has updated an activity you're going to: <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
        end
      end
      redirect_to @activity
    else
      render :edit
    end
  end

  def create
    params = activity_params
    params[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
    @activity = Activity.create(params)
    @activity.user_id = current_user.id
    if @activity.save
      # Notfiy all followers of this organizer that a new activity has been created.
      current_user.followers.each do |follower|
        follower.notify("#{current_user.name} created a new activity", "#{current_user.name} has created a new activity:  <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
      end
      Transaction.create!(transaction_type_id: 2, user_id: current_user.id, amount: 1, balance: ((current_user.profile.nonprofit == 1) || current_user.profile.ambassador == 1)?Transaction.get_balance(current_user):(Transaction.get_balance(current_user) - 1))
      redirect_to @activity
    else
      render :new
    end
  end

  def rsvp
    rsvp = Rsvp.new(activity_id: params[:activity_id], user_id: params[:user_id])

    # Notfiy the creator that a new user is going
    @activity = Activity.find(params[:activity_id])
    @organizer = User.find(@activity.user_id)
    @organizer.notify("#{current_user.name} is coming!", "#{current_user.name} is attending your activity: <a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

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
