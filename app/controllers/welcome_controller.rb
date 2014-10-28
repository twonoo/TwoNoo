class WelcomeController < ApplicationController
  def index
    #@trending = Activity.trending('Denver, CO')
  end

  def trending
    @trending = Activity.trending(params[:location].present? ? params[:location] : nil)
     respond_to do |format|
       format.html { render :partial => 'trending' }
     end
  end

  def coming_soon
  	@title = 'TwoNoo is Coming Soon!'
  end

  def search
    @showNoResults = true
    @outsideSupportedArea = false
  	# Setup location constraints
    denver = [39.737567, -104.9847179]
    pittsburgh = [40.44062479999999, -79.9958864]
    fairbanks = [64.8377778, -147.7163889]

    # Convert search parameter to coordinates
    unless params[:lat].empty? && params[:lng].empty?
      search_coordinates = [params[:lat].to_f, params[:lng].to_f]
      logger.info "using passed in coords"
    else
      search_coordinates = Geocoder.search(params[:location]).first.coordinates
    end
    unless (Geocoder::Calculations.distance_between(search_coordinates, denver) < 300 ||
           Geocoder::Calculations.distance_between(search_coordinates, pittsburgh) < 100 ||
           Geocoder::Calculations.distance_between(search_coordinates, fairbanks) < 600)
      #redirect_to root_path, notice: "You're trying to search outside of the area"
      #@showNoResults = false
      flash.now[:notice] = "You are trying to search outside TwoNoo's currently supported areas, but here are some results from other locations..."
      @outsideSupportedArea = true
    end

    # Determine Type
    case params[:type]
      when "Sport"
        type = 1
      when "Art"
        type = 2
      when "Business"
        type = 3
      when "Outdoor"
        type = 4
      when "Eat & Drink"
        type = 5
      when "Nightlife"
        type = 6
      when "Community"
        type = 7
      else
        type = nil
    end

    # Determine date range
    if params[:when].present?
      case params[:when]
        when "Today"
          end_date = DateTime.tomorrow
        when "This Week"
          end_date = DateTime.now.at_end_of_week
        when "This Weekend"
          end_date = DateTime.now.at_end_of_week
          from_date = end_date - 2
        when "Next Two Weeks"
          end_date = 2.weeks.from_now
        else
          end_date = 1.month.from_now 
      end
      from_date = DateTime.now.beginning_of_day unless from_date
    else
      from_date = Time.strptime(params[:from_date], '%m/%d/%Y')
      end_date = Time.strptime(params[:to_date], '%m/%d/%Y')
    end

    # Get Timezone
    tz = Timezone::Zone.new(:latlon => search_coordinates).active_support_time_zone

    # Build search query for activities
    @activities = Activity.terms(params[:terms])
    @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
    @activities = @activities.where('datetime BETWEEN ? AND ?', from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
    #logger.info "**********!!!!!!!**********     #{from_date.in_time_zone(tz).utc} -  #{end_date.in_time_zone(tz).utc}"
    @activities = @activities.where('cancelled = ?', false)
    unless @outsideSupportedArea
      @activities = @activities.within(params[:distance], origin: search_coordinates).order('datetime ASC')
    end
    @activities = @activities.order('datetime ASC')


    @users = Profile.terms(params[:terms])

    search_history = Search.new(search: params[:terms], location: params[:location])
    search_history.user_id = current_user.id if current_user
    search_history.save!
    
    if @activities.blank? && @users.blank? && @showNoResults
      render 'noresults' 
    end
  end

  def invite_people
    UserMailer.delay.twonoo_invite(current_user, params[:emails])
  end

end
