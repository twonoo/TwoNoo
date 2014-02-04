class ActivityType < ActiveRecord::Base
  has_and_belongs_to_many :activity
end
