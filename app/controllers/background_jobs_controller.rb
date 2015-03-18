class BackgroundJobsController < ApplicationController

  def create
    user = User.unscoped.where(id: current_user.id).first
    user.find_people
    render json: {}, status: 200
    #job = FindPeopleJob.perform_later(current_user.id)
    #if job && job.job_id
      #render json: {}, status: 200
    #else
     # render json: {}, status: 500
    #end
  end

end
