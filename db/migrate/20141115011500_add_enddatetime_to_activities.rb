class AddEnddatetimeToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :enddatetime, :datetime
  end
end
