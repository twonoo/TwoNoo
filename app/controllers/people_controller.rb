class PeopleController < ApplicationController

  before_filter :authenticate_user!

  def index
    @people = current_user.recommended_followers
  end

end
