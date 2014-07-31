class CreateActivitiesActivityTypes < ActiveRecord::Migration
  def change
    create_table :activities_activity_types, id: false do |t|
      t.integer :activity_id
      t.integer :activity_type_id

      t.timestamps
    end
  end
end
