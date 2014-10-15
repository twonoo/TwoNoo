class AlertsController < ApplicationController

  before_filter :authenticate_user!
  
  def index
  end

  def new
  end

  def create
  	a = Alert.create(keywords: params[:terms], distance: params[:distance], location: params[:location], user_id: current_user.id)
  	if a.save
  		redirect_to alerts_path, notice: "Alert for \"#{params[:terms]}\" created successfully!"
  	else
  		redirect_to alerts_path, alert: "Alert for \"#{params[:terms]}\" could not be created!"
  	end
  end

  def destroy
  	a = Alert.find(params[:id])
    a.destroy
  	redirect_to alerts_path, notice: "Alert for \"#{a.keywords}\" has been deleted!"
  end
end
