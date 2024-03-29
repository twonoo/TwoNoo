class FindPeopleJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.unscoped.where(id: user_id).first
    user.find_people
  end
end
