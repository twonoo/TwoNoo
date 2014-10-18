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
      UserMailer.delay.feedback_from_user(current_user, params[:feedback])
    else
      UserMailer.delay.feedback(params[:feedback])
    end
  end
end
