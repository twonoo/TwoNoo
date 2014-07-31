class ProfileController < ApplicationController
  def index
  end

  def edit
  end

  def notifications
  end

  def privacy
  end

  def followers
    @followers = User.find(params[:id]).followers
  end

  def following
    @following = User.find(params[:id]).followed_users
  end
end
