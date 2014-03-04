class WelcomeController < ApplicationController
  def index
    if signed_in?
      redirect_to activities_path
    end
  end
end
