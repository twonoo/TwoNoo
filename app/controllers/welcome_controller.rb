class WelcomeController < ApplicationController

  before_filter :add_user_category, only: :search

  def index
    @suggested_search_terms = [*Interest.all.pluck(:name)].uniq.sort_by { |word| word.downcase }
    @suggested_city_search_terms = US_CITIES
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
    if params[:terms] == 'All'
      searched_interest_ids = Interest.all.map(&:id)
    else
      searched_interest_ids = params[:term_ids].split(',').map(&:to_i)
    end

    # Setup location constraints
    denver = [39.737567, -104.9847179]
    pittsburgh = [40.44062479999999, -79.9958864]
    fairbanks = [64.8377778, -147.7163889]

    # Convert search parameter to coordinates
    lat,lon,outside_supported_area = determine_lat_lon
    search_coordinates = [lat.to_f,lon.to_f]

    params[:distance] ||= 25
    params[:terms] ||= ''

    # Determine date range
    end_date, from_date = determine_search_dates

    # Get timezone
    tz = Timezone::Zone.new(:latlon => denver).active_support_time_zone

    # Build up the search
    @activities = Activity.having_interests(searched_interest_ids)
                          .where('cancelled IS NOT TRUE')
                          .order('datetime ASC')
    if end_date.present?
      @activities = @activities.between_dates(from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
    else
      @activities = @activities.after_date(from_date.in_time_zone(tz).utc)
    end

    @activities = @activities.within(params[:distance], origin: search_coordinates) unless outside_supported_area
    if @activities.count == 0
      # If no activities match the search parameters, we want to loosen the requirements, 
      # ignoring the type requirements
      @showCreateAlert = true

      @activities = Activity.joins(:interests)
                            .where('cancelled IS NOT TRUE')
                            .order('datetime ASC')
      if end_date.present?
        @activities = @activities.between_dates(from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
      else
        @activities = @activities.after_date(from_date.in_time_zone(tz).utc)
      end

      @activities = @activities.within(params[:distance], origin: search_coordinates) unless outside_supported_area
    end

    @users = Profile.having_interests(searched_interest_ids).where("closed_at IS NULL")
    @users = @users.order("IF(city_state_latitude,1,0) desc").by_distance(origin: search_coordinates)
    if @users && params[:location] && params[:location].include?(',')
      state = params[:location].split(',').last.strip.downcase
      @users = @users.where("(profiles.state IS NULL OR profiles.state = #{ActiveRecord::Base.connection.quote(state)})")
    end

    @page_increment = 9
    @users_offset = [params[:users_offset].to_i, 0].max
    @users_max = [params[:users_max].to_i, (@page_increment + 10)].max
    @activities_offset = [params[:activities_offset].to_i, 0].max
    @activities_max = [params[:activities_max].to_i, @page_increment].max
    @total_users = @users.present? ? @users.count : 0
    @total_activities = @activities.present? ? @activities.count : 0

    @search_params = params.slice(:terms, :when, :from_date, :to_date, 
                                  :distance, :lat, :lng, :location).to_query

    @users = @users[@users_offset..@users_max] if @users.present?
    @activities = @activities[@activities_offset..@activities_max] if @activities.present?

    search_history = Search.new(search: (params[:terms]), location: params[:location])
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

  private

  def add_user_category
    return unless params[:terms].present?
    interest_updated = false
    param_term        = params[:terms].split(',')
    return if param_term.blank? || param_term.first.downcase=='all' || current_user.blank?
    current_user_term = current_user.interests.map(&:name)
    (param_term - current_user_term).each do |int_name|
      interest = Interest.find_by_name int_name
        if interest.present?
          InterestsUser.create(
              user_id: current_user.id,
              interest_id: interest.id
          )
          interest_updated = true
        end
      flash[:success] = 'Selected interests have been added to profile.' if interest_updated
    end
  end
 
  def determine_lat_lon
    if (params[:lat].present? && params[:lng].present?)
      lat = params[:lat]
      lon = params[:lng]
    else
      # TODO: add in looking cookies
      # First, look at IP address, then look at passed in location
      search_coordinates = Geocode.coordinates_by_ip(request.remote_ip) rescue nil
      search_coordinates ||= Geocoder.search("#{params[:location].split(',').first}, #{params[:location].split(',').last}").first.coordinates rescue nil
      if search_coordinates
        lat = search_coordinates[0]
        lon = search_coordinates[1]
      else
        search_location = Geocoder.search(params[:location]).first
        lat = search_location && search_location.latitude
        lon = search_location &&search_location.longitude
      end
    end

    if !defined?(search_coordinates) || search_coordinates.nil?
      outside_supported_area = true
    else
      outside_supported_area = false
    end

    return lat,lon,outside_supported_area
  end

  def determine_search_dates
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
      when nil
        from_date = Date.strptime(params[:from_date], '%m/%d/%Y') if params[:from_date].present? rescue nil
        end_date = Date.strptime(params[:to_date], '%m/%d/%Y') if params[:to_date].present? rescue nil
      else
        end_date = 1.month.from_now
    end

    from_date ||= DateTime.now.beginning_of_day
    return end_date, from_date
  end

end
