class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  before_filter :set_cache_buster, :set_cookies#, :set_city

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

    unless cookies[:lat].nil? && cookies[:lng].nil && cookies[:city].nil? && cookies[:state].nil?
      logger.info "No geocode cookies!"
      if user_signed_in? && !(current_user.profile.city.nil? || current_user.profile.state.nil?)
        cookies[:city] = { value: current_user.profile.city, expires: 365.day.from_now }
        cookies[:state] = { value: current_user.profile.state, expires: 365.day.from_now }

        geocode = Geocode.where(city: current_user.profile.city).where(state: current_user.profile.state).first

        unless geocode.nil?
          cookies[:lat] = { value: geocode.latitude, expires: 365.day.from_now }
          cookies[:lng] = { value: geocode.longitude, expires: 365.day.from_now }
        end
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:uid, :provider, profile_attributes: [:id, :first_name, :last_name, :birthday, :gender, :postcode, :about_me, :profile_picture, :nonprofit, :referrer]]
    devise_parameter_sanitizer.for(:account_update) << [:uid, :provider, profile_attributes: [:first_name, :last_name, :birthday, :gender, :postcode, :about_me, :profile_picture, :nonprofit, :ambassador]]
  end

end
