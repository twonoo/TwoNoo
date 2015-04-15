class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :activity

  def self.add_or_remove(params)
    existing_like = where(user_id: params[:user_id], activity_id: params[:activity_id]).select(:id)
    existing_like.present? ? (existing_like.first.delete and return false) : (create(params) and return true)
  end

end
