class InterestsController < ApplicationController

  def index
    ViewLog.find_or_create_by(user_id: current_user.id, view_name: 'interests/index')
    @interests = Interest.all.order(:name)
  end

  def update
    if params[:interests].present?
      current_user.interests.delete_all

      params[:interests].each do |interest|
        interest_record = Interest.where(code: interest).first
        interests_user_record = InterestsUser.new(
            user_id: current_user.id,
            interest_id: interest_record.id
        )
        if params[:interests_options].present? && params[:interests_options][interest_record.code].present?
          interests_user_record.interests_option_id = params[:interests_options][interest_record.code]
        end

        interests_user_record.save
      end

      flash[:success] = 'Interests saved'
    end

    redirect_to root_path
  end

end