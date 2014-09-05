class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
  end

  def num_messages
    respond_to do |format|
      format.js
    end
  end

  def show
  end

  def display_messages
    respond_to do |format|
      format.html { render :partial => 'messages' }
    end
  end


  private

end

