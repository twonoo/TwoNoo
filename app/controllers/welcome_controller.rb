class WelcomeController < ApplicationController
  def index
  end

  def coming_soon
  	@title = 'TwoNoo is Coming Soon!'
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
    @activities = @activities.joins(:activity_types).where('activity_types.id' => params[:type]) unless params[:type].blank?
    @activities = @activities.where('datetime BETWEEN ? AND ?', from_date.in_time_zone(tz).utc, end_date.in_time_zone(tz).utc)
    #logger.info "**********!!!!!!!**********     #{from_date.in_time_zone(tz).utc} -  #{end_date.in_time_zone(tz).utc}"
    @activities = @activities.where('cancelled = ?', false)
    @activities = @activities.within(params[:distance], origin: search_coordinates).order('datetime ASC')

    @users = Profile.terms(params[:terms])
    
    if @activities.blank? && @users.blank?
      render 'noresults' 
    end
  end

end
