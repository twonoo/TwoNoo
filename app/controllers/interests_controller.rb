class InterestsController < ApplicationController

  def index
    ViewLog.find_or_create_by(user_id: current_user.id, view_name: 'interests/index')
    @interests = Interest.all.order(:name)
  end

  def update
    current_user.interests.delete_all

    params[:interests].each do |interest|
      interest_record = Interest.where(code: interest).first
      current_user.interests << interest_record
    end

    flash[:success] = 'Interests saved'
    redirect_to interests_index_path
  end

end