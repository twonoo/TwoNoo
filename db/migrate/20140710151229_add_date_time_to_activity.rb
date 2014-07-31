class AddDateTimeToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :datetime, :datetime
  end
end
