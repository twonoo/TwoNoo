class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def create
  end

  def num_notifications
    respond_to do |format|
      format.js
    end
  end

  def show
    redirect_to conversations_path(:id => conversation.id)
  end

  def display_notifications
    respond_to do |format|
      format.html { render :partial => 'notifications' }
    end
  end


  private

end

