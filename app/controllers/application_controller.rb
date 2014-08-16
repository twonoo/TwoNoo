class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?
  
  before_filter :set_cache_buster

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [profile_attributes: [:id, :first_name, :last_name, :birthday, :gender, :postcode, :about_me, :profile_picture], :uid, :provider]
    devise_parameter_sanitizer.for(:account_update) << [profile_attributes: [:first_name, :last_name, :birthday, :gender, :postcode, :about_me, :profile_picture]]
  end
end
