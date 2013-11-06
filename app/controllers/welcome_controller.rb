class WelcomeController < ApplicationController
  def index
    if signed_in?
      redirect_to welcome_user_path
    end
  end
end
