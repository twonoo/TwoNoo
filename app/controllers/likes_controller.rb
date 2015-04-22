class LikesController < ApplicationController
  before_filter :authenticate_user!, only: :create

  def create
    params.merge!(user_id: current_user.id)
    params.merge!(referrer_uri: request.referrer) if params[:referrer_uri].blank?

    if !permitted.values_at(:activity_id, :referrer_uri).include? nil
      render json: {created: Like.add_or_remove(permitted)}, status: 200
    else
      render json: {error: 'missing required parameters'}, status: :unprocessable_entity
    end
  end

  def data
    count = Like.where(activity_id: params[:activity_id]).count
    user_has_liked = Like.exists?(activity_id: params[:activity_id], user_id: params[:user_id])
    render json: {count: count, user_has_liked: user_has_liked}, status: 200
  end

  private

  def permitted
    params.permit(:user_id, :activity_id, :referrer_uri)
  end

end