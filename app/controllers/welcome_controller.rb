class WelcomeController < ApplicationController
  def index
    @trending = Activity.trending(nil)
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
    @outsideSupportedArea = false
  	# Setup location constraints
    denver = [39.737567, -104.9847179]
    pittsburgh = [40.44062479999999, -79.9958864]
    fairbanks = [64.8377778, -147.7163889]

    # Convert search parameter to coordinates
    if (params[:lat].present? || params[:lng].present?)
      lat = params[:lat]
      lon = params[:lng]
      search_coordinates = [params[:lat].to_f, params[:lng].to_f]
      logger.info "using passed in coords"
    elsif !(params[:location].present?)
      # TODO: add in looking cookies

      # try to get it by the IP address
      begin
        search_coordinates = Geocode.coordinates_by_ip(request.remote_ip)
        lat = search_coordinates[0]
        lon = search_coordinates[1]
      rescue
        logginer.info "Geocode by IP failed"
      end
    end

    if (!defined?(search_coordinates) || search_coordinates.nil?)
      # Need to have this look at the GeoCodecache
      begin
        search_location = Geocoder.search(params[:location]).first
        search_coordinates = search_location.coordinates
        lat = search_location.latitude
        lon = search_location.longitude
      rescue
        logginer.info "Geocode by location failed"
      end
    end

    if !defined?(search_coordinates) || search_coordinates.nil?
      @outsideSupportedArea = true
    end
    
#    unless (Geocoder::Calculations.distance_between(search_coordinates, denver) < 300 ||
#           Geocoder::Calculations.distance_between(search_coordinates, pittsburgh) < 100 ||
#           Geocoder::Calculations.distance_between(search_coordinates, fairbanks) < 600)
#      flash.now[:notice] = "You are trying to search outside TwoNoo's currently supported areas, but here are some results from other locations..."
#      @outsideSupportedArea = true
#    end

    # Determine Type
    type = ActivityType.where(activity_type: params[:type]).first.id rescue type = nil

    params[:distance] = 25 unless params[:distance].present?
    params[:terms] = '' unless params[:terms].present?

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
      from_date = (params[:from_date].present? ? Time.strptime(params[:from_date], '%m/%d/%Y') : Time.now )
      end_date = (params[:to_date].present? ? Time.strptime(params[:to_date], '%m/%d/%Y') : Time.now + 14.days )
    end

    # Get Timezone
    #begin
      #tz = Timezone::Zone.new(:latlon => search_coordinates).active_support_time_zone
    #rescue
      tz = Timezone::Zone.new(:latlon => denver).active_support_time_zone
    #end

    # Build search query for activities
    @activities = Activity.terms(params[:terms])
    @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
    @activities = @activities.where('(datetime BETWEEN ? AND ?) OR (enddatetime BETWEEN ? AND ?) OR ((? < enddatetime) AND (? > datetime))',
        from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
        from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
        from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
    #logger.info "**********!!!!!!!**********     #{from_date.in_time_zone(tz).utc} -  #{end_date.in_time_zone(tz).utc}"
    @activities = @activities.where('cancelled = ?', false)
    unless @outsideSupportedArea
      @activities = @activities.within(params[:distance], origin: search_coordinates).order('datetime ASC')
    end
    @activities = @activities.order('datetime ASC')

    @showCreateAlert = false

    if @activities.blank?
      @showCreateAlert = true

      @activities = Activity.terms(params[:terms])
      @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
      @activities = @activities.where('(datetime BETWEEN ? AND ?) OR (enddatetime BETWEEN ? AND ?) OR ((? < enddatetime) AND (? > datetime))',
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      @activities = @activities.where('cancelled = ?', false)
      @activities = @activities.order('datetime ASC')
    end

    if @activities.blank?
      @showCreateAlert = true

      @activities = Activity.all
      @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
      @activities = @activities.where('(datetime BETWEEN ? AND ?) OR (enddatetime BETWEEN ? AND ?) OR ((? < enddatetime) AND (? > datetime))',
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      @activities = @activities.where('cancelled = ?', false)
      unless @outsideSupportedArea
        @activities = @activities.within(params[:distance], origin: search_coordinates).order('datetime ASC')
      end
      @activities = @activities.order('datetime ASC')
    end

    if @activities.blank?
      @showCreateAlert = true
      
      @activities = Activity.all
      @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
      @activities = @activities.where('(datetime BETWEEN ? AND ?) OR (enddatetime BETWEEN ? AND ?) OR ((? < enddatetime) AND (? > datetime))',
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc,
          from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      @activities = @activities.where('cancelled = ?', false)
      @activities = @activities.order('datetime ASC')
    end


    @users = Profile.terms(params[:terms])

    search_history = Search.new(search: params[:terms], location: params[:location])
    search_history.user_id = current_user.id if current_user
    search_history.save!

    if current_user
      if current_user.last_search_location != params[:location]
        u = User.find(current_user)
        u.last_search_location = params[:location]
        u.last_search_lat = lat
        u.last_search_lon = lon
        u.save!
      end
    end
  end

  def invite_people
    UserMailer.delay.twonoo_invite(current_user, params[:emails])
  end

end
