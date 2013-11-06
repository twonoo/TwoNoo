class ActivitydateAndTime < ActiveRecord::Migration
  def change
    add_column :activities, :ActivityDate, :date
    add_column :activities, :ActivityTime, :time
    remove_column :activities, :StartDateTime, :datetime
    remove_column :activities, :EndDateTime, :datetime
    
  end
end
