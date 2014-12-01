class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  before_filter :set_cache_buster, :set_cookies, :store_location

  config.time_zone = 'Mountain Time (US & Canada)'


  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get? 
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/password/edit" &&
        request.path != "/users/confirmation" &&
        request.path != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def set_city
    # session[:city] = request.location.city if session[:city].blank?
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def set_cookies
    cookies[:referrer] = { value: params[:referrer], expires: 1.day.from_now } if params[:referrer]

    logger.info "cookies: #{cookies[:lat]} #{cookies[:lng]} #{cookies[:city]} #{cookies[:state]}"
    if cookies[:lat].nil? || cookies[:lng].nil? || cookies[:city].nil? || cookies[:state].nil?
      logger.info "No geocode cookies!"
      if user_signed_in? && !(current_user.profile.city.nil? || current_user.profile.state.nil?)
        cookies[:city] = { value: current_user.profile.city, expires: 365.day.from_now }
        cookies[:state] = { value: current_user.profile.state, expires: 365.day.from_now }

        geocode = Geocode.where(city: current_user.profile.city).where(state: current_user.profile.state).first

        unless geocode.nil?
          cookies[:lat] = { value: geocode.latitude, expires: 365.day.from_now }
          cookies[:lng] = { value: geocode.longitude, expires: 365.day.from_now }
        end
      else
        begin
          logger.info "IP Address: #{request.remote_ip}"
          results = Geocoder.search(request.remote_ip)
          logger.info "results: #{results}"

          result = results.first
          unless result.nil?
            logger.info "city: #{result.city}"
            logger.info "state: #{result.state_code}"

            if result.city.present? and result.state_code.present?
              cookies[:city] = { value: result.city, expires: 365.day.from_now }
              cookies[:state] = { value: result.state_code, expires: 365.day.from_now }

              geocode = Geocode.where(city: result.city).where(state: result.state_code).first

              unless geocode.nil?
                cookies[:lat] = { value: geocode.latitude, expires: 365.day.from_now }
                cookies[:lng] = { value: geocode.longitude, expires: 365.day.from_now }
              end
            end
          end
        rescue
          logger.info "IP Geocode failed"
        end
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:uid, :provider, :sign_up_ip, profile_attributes: [:id, :first_name, :last_name, :birthday, :gender, :postcode, :about_me, :profile_picture, :nonprofit, :referrer]]
    devise_parameter_sanitizer.for(:account_update) << [:uid, :provider, profile_attributes: [:first_name, :last_name, :birthday, :gender, :postcode, :about_me, :profile_picture, :nonprofit, :ambassador]]
  end

end
