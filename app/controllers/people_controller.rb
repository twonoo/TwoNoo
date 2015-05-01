class PeopleController < ApplicationController

  before_filter :authenticate_user!

  def index
    @people = current_user.recommended_followers.where(ignored: false)
  end

  def destroy
    user = current_user.recommended_followers.where(recommended_follower_id: params[:id]).first
    if user
      user.update_attribute(:ignored, true)
      render json: {success: true}, status: 200
    else
      render json: {success: true}, status: :unprocessable_entity
    end
  end

end
