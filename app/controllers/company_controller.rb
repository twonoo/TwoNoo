class CompanyController < ApplicationController
  def about
  end

  def contact
  end

  def privacy
  end

  def terms
  end

  def feedback
    if current_user
      UserMailer.feedback_from_user(current_user, params[:feedback]).deliver
    else
      UserMailer.feedback(params[:feedback]).deliver
    end
  end
end
