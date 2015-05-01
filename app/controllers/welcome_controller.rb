class WelcomeController < ApplicationController
  def index
    @suggested_search_terms = [*Interest.all.pluck(:name) + ActivityType.all.pluck(:activity_type)].uniq.sort_by { |word| word.downcase }
    @suggested_city_search_terms = US_CITIES

    if current_user.present?
      view_log = ViewLog.find_or_initialize_by(user_id: current_user.id, view_name: 'welcome/index')
      unless view_log.persisted?
        view_log.save
        FindPeopleJob.perform_later(current_user.id) if current_user
      end
    end
  end

  def trending
    @trending = Activity.trending(params[:location]).to_a.sort_by { |x| x.datetime }

    case @trending.length
      when 13..15
        @trending = @trending.take(12)
      when 9..11
        @trending = @trending.take(8)
      when 0..7
        @trending = @trending.take(4)
      else
        @trending = @trending.take(16)
    end

    respond_to do |format|
      format.html { render :partial => 'trending' }
    end
  end

  def coming_soon
    @title = 'TwoNoo is Coming Soon!'
  end

  def search
    if params[:terms].present?
      params[:terms] = params[:terms].gsub(/[^0-9A-Za-z]/, ' ').strip
    else
      params[:terms] = ''
    end


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
        logger.info "Geocode by IP failed"
      end
    else
      begin
        search_coordinates = Geocoder.search("#{params[:location].split(',').first}, #{params[:location].split(',').last}").first.coordinates
        lat = search_coordinates[0]
        lon = search_coordinates[1]
      rescue
        logger.info "Geocode by IP failed"
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
        logger.info "Geocode by location failed"
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

    params[:distance] = 25 unless params[:distance].present?
    params[:terms] = '' unless params[:terms].present?

    end_date = nil
    from_date = nil

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
        when "Anytime"
          end_date = nil
        else
          end_date = 1.month.from_now
      end
    else
      from_date = Date.strptime(params[:from_date], '%m/%d/%Y') if params[:from_date].present? rescue from_date = DateTime.now.beginning_of_day
      end_date = Date.strptime(params[:to_date], '%m/%d/%Y') if params[:to_date].present? rescue end_date = nil
    end

    from_date = DateTime.now.beginning_of_day unless from_date

    #fdsafasd
    # Get Timezone
    #begin
    #tz = Timezone::Zone.new(:latlon => search_coordinates).active_support_time_zone
    #rescue
    tz = Timezone::Zone.new(:latlon => denver).active_support_time_zone
    #end

    #Tag results
    tag_type = ActivityType.where(activity_type: params[:terms]).first
    tag_activities = Activity.where(cancelled: false).joins(:activity_types)
                         .where('activity_types.id' => tag_type.id).where('cancelled = ?', false).after_date(from_date.in_time_zone(tz).utc).where('cancelled = ?', false) if tag_type

    #Search results
    search_activities = []
    if end_date.present?
      search_activities = Activity.terms(params[:terms]).between_dates(from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
    else
      search_activities = Activity.terms(params[:terms]).after_date(from_date.in_time_zone(tz).utc).where('cancelled = ?', false)
    end

    type = ActivityType.where(activity_type: (params[:type] || 'All')).first
    search_activities = search_activities.joins(:activity_types).where('activity_types.id' => type.id).where('cancelled = ?', false) if type

    #Join both results
    both_activities = nil
    if search_activities.present? && tag_activities.present?
      both_activities = search_activities.all | tag_activities.all
      both_activities = Activity.where(id: both_activities.map(&:id)).order('datetime ASC')
    elsif search_activities.present?
      both_activities = search_activities
    elsif tag_activities.present?
      both_activities = tag_activities
    end

    unless @outsideSupportedArea
      both_activities = both_activities.within(params[:distance], origin: search_coordinates).order('datetime ASC') if both_activities
    end

    @activities = both_activities.order('datetime') if both_activities
    @showCreateAlert = false

    if @activities.blank?
      @showCreateAlert = true

      @activities = Activity.terms(params[:terms])
      @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
      if end_date.present?
        @activities = @activities.between_dates(from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      else
        @activities = @activities.after_date(from_date.in_time_zone(tz).utc)
      end

      @activities = @activities.where('cancelled = ?', false)
      @activities = @activities.order('datetime ASC')
    end

    if @activities.blank?
      @showCreateAlert = true

      @activities = Activity.all
      @activities = @activities.joins(:activity_types).where('activity_types.id' => type) unless type.nil?
      if end_date.present?
        @activities = @activities.between_dates(from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      else
        @activities = @activities.after_date(from_date.in_time_zone(tz).utc)
      end
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
      if end_date.present?
        @activities = @activities.between_dates(from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      else
        @activities = @activities.after_date(from_date.in_time_zone(tz).utc)
      end
      @activities = @activities.where('cancelled = ?', false)
      @activities = @activities.order('datetime ASC')
    end

    @users = Profile.terms(params[:terms])
    if @users && params[:location] && params[:location].include?(',')
      state = params[:location].split(',').last.strip
      @users = @users.select { |u| u.state.blank? || u.state.downcase == state.downcase }
    end

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
