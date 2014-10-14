class GeocodeController < ApplicationController
  def search
  	location = Geocoder.search(params[:location]).first
  	data = {location: (location.city + ", " + location.state_code) }
		respond_to do |format|
		  format.json { render :json => data}
		end
  end

  def searchCityState
  	location = Geocoder.search(params[:location]).first
  	data = {city: location.city, state: location.state_code }
		respond_to do |format|
		  format.json { render :json => data}
		end
  end
end
