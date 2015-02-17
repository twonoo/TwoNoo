class ActivitiesController < ApplicationController
  require 'mandrill'
  before_filter :authenticate_user!, :except => [:index, :search, :show]

  def add_to_gcal
    respond_to do |format|
      format.html do
        cookies[:activityid] = params[:id] if params[:id].present?
        user = current_user
        access_token = nil

        # If we are gettign the callback from the authorization request or we have a refresh token then get a new authorization token
        # do we need to ask the user for authorization?
        if params[:code].present? || (user.gcal_token.present? && ((user.gcal_token_issued_at + user.gcal_token_expires_in) > Time.now())) || user.gcal_refresh_token.present?

          #Do we need to get an access token
          if params[:code].present? || ((user.gcal_token_issued_at + user.gcal_token_expires_in) < Time.now())
            data = {
                :redirect_uri => ENV['BASEURL'] + ENV['GOOGLE_REDIRECT_URI'],
                :client_id => ENV['GOOGLE_KEY'],
                :client_secret => ENV['GOOGLE_SECRET']
            }

            if params[:code].present?
              data.merge(code: params[:code], grant_type: 'authorization_code')
            elsif user.gcal_refresh_token.present?
              data.merge(refresh_token: user.gcal_refresh_token, grant_type: 'refresh_token')
            else
              redirect_to '/users/auth/google_oauth2' and return
            end

            @response = HTTParty.post('https://accounts.google.com/o/oauth2/token', body: data)

            if @response["access_token"].present?
              # Save your token
              access_token = @response["access_token"]
              expires_in = @response["expires_in"]
              refresh_token = @response["refresh_token"]

              # Save the tokens to the DB
              user.gcal_token = access_token
              user.gcal_token_issued_at = Time.now()
              user.gcal_token_expires_in = expires_in
              user.gcal_refresh_token = refresh_token
              user.save!
            else
              redirect_to '/users/auth/google_oauth2' and return
            end
          else
            access_token = user.gcal_token
          end

          activity = Activity.where(id: cookies[:activityid]).first

          location = ''
          location << activity.location_name + ', ' if activity.location_name.present?
          location << activity.street_address_2 + ', ' if activity.street_address_2.present?
          location << activity.city + ', ' if activity.city.present?
          location << activity.state + ', ' if activity.state.present?

          event = {
              'summary' => activity.activity_name,
              'description' => activity.description,
              'location' => location,
              'start' => {
                  'dateTime' => "#{activity.datetime.strftime('%Y-%m-%dT%H:%M:%S')}#{ActiveSupport::TimeZone[activity.tz].formatted_offset}"
              },
              'end' => {
                  'dateTime' => "#{(activity.enddatetime.present? ? activity.enddatetime : activity.datetime + 1.hours).strftime('%Y-%m-%dT%H:%M:%S')}#{ActiveSupport::TimeZone[activity.tz].formatted_offset}"
              }
          }

          response = HTTParty.post("https://www.googleapis.com/calendar/v3/calendars/primary/events?access_token=#{access_token}", body: event.to_json, headers: {'Content-Type' => 'application/json'})
          logger.info response.inspect
        else
          redirect_to '/users/auth/google_oauth2' and return
        end
      end
      format.ics do
        activity = Activity.find_by_id(params[:id])
        event = Icalendar::Event.new
        event.dtstart = activity.datetime.strftime("%Y%m%dT%H%M%S")
        event.dtend = (activity.enddatetime.present? ? activity.enddatetime : activity.datetime + 1.hours).strftime("%Y%m%dT%H%M%S")
        event.summary = activity.activity_name
        event.description = activity.description
        event.location = "#{activity.location_name}, #{activity.street_address_1}, #{activity.street_address_2}, #{activity.city}, #{activity.state}"
        #event.klass = "PUBLIC"
        event.created = activity.created_at
        event.last_modified = activity.updated_at
        event.uid = event.url = "https://www.twonoo.com/activity/#{activity.id}"

        calendar = Icalendar::Calendar.new
        calendar.add_event(event)
        calendar.publish
        render :text => calendar.to_ical
        return
      end
    end

  end

  def attending
    @rsvps = Rsvp.where(user_id: params[:id])
  end

  def index
  end

  def search

  end

  def user
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

  def show

    @activity = Activity.find_by_id(params[:id])

    if @activity.nil?
      redirect_to root_url
      return
    end

    @activity.increase_view

    @organizer = User.find(@activity.user_id)
  end

  def new
    if (Transaction.get_balance(current_user) > 0) \
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
        unless @user.nil? || @user == @activity.user
          if @activity.cancelled
            @user.notify("#{@activity.activity_name} has been cancelled", "(<a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>)")
            UserMailer.delay.activity_cancelled(@user, @activity)
          else
            @user.notify("#{@activity.activity_name} is back on!!", "(<a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>)")
            UserMailer.delay.attending_activity_update(@user, @activity)
          end
        end
      end
      redirect_to @activity
    else
      render :edit
    end
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
          @user.notify("#{current_user.name} commented on an activity you're going to", "<a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

          UserMailer.delay.comment_on_attending_activity(@user, @activity, current_user, @comment.comment)
        end
      end

      @organizer = User.find(@activity.user_id)
      if current_user != @organizer
        UserMailer.delay.comment_on_owned_activity(@organizer, @activity, current_user, @comment.comment)
      end
    end

    redirect_to :back
  end

  def copy
    ## Load the activity
    old_activity = Activity.find_by_id(params[:id])

    unless old_activity.nil?
      @activity = old_activity.dup
      @activity.activity_type_ids = old_activity.activity_type_ids
      logger.info @activity.activity_type_ids
    end
    render :new
  end

  def create
    parms = activity_params
#    dt_invalid = false
#    begin
#      parms[:datetime] = Time.strptime(activity_params[:datetime], '%m/%d/%Y %I:%M %p')
#    rescue
#      dt_invalid = true
#      parms[:datetime] = Time.now
#    end

    if params[:lat].present? && params[:lng].present?
      parms[:latitude] = params[:lat]
      parms[:longitude] = params[:lng]
    end

    @activity = Activity.create(parms)
    @activity.user_id = current_user.id

    if @activity.save
      # Charge the organizer
      Transaction.create!(transaction_type_id: 2, user_id: current_user.id, amount: 1, balance: ((current_user.profile.nonprofit == 1) || current_user.profile.ambassador == 1) ? Transaction.get_balance(current_user) : (Transaction.get_balance(current_user) - 1))

      # Have the organizer RSVP to their own activity
      rsvp = Rsvp.new(activity_id: @activity.id, user_id: current_user.id)
      rsvp.save

      # Notfiy all followers of this organizer that a new activity has been created.
      current_user.followers.each do |follower|
        UserMailer.delay.new_following_activity(follower, current_user, @activity)
        follower.notify("#{current_user.name} created a new activity", "<a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")
      end

      redirect_to @activity
    else
#      if dt_invalid
#        @activity.errors.add(:base, "#{activity_params[:datetime]} is not a valid date.  Please enter dates in the format mm/dd/yyyy HH:MM AM/PM")
#        @activity.datetime = Time.now
#      end
      render :new
    end
  end

  def rsvp
    rsvp = Rsvp.new(activity_id: params[:activity_id], user_id: params[:user_id])

    # Notfiy the creator that a new user is going
    @activity = Activity.find(params[:activity_id])
    @organizer = User.find(@activity.user_id)

    unless current_user == @organizer
      @organizer.notify("#{current_user.name} is coming to your activity!", "<a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

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

  def update
    @activity = Activity.find(params[:id])
    params = activity_params
    @activity.activity_type_ids=params[:activity_type_ids]

    @activity.update(params)

    if @activity.save
      # Get the rsvp'd users
      @rsvps = Rsvp.where(activity_id: @activity.id).all
      @rsvps.each do |rsvp|
        @user = User.find_by_id(rsvp.user_id)
        unless @user.nil? || (current_user == @user)
          @user.notify("#{current_user.name} updated an activity you're going to", "<a href='#{root_url}/activities/#{@activity.id}'>#{@activity.activity_name}</a>")

          UserMailer.delay.attending_activity_update(@user, @activity)
        end
      end
      redirect_to @activity
    else
      render :edit
    end
  end

  private

  def activity_params
    params.require(:activity).permit(:activity_name, :location_name, :street_address_1, :street_address_2, :city, :state, :website, :description, :rsvp, :latitude, :longitude, :image, :date, :time, :enddate, :endtime, activity_type_ids: [])
  end
end
