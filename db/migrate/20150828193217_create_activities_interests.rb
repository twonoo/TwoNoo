class CreateActivitiesInterests < ActiveRecord::Migration
  def change
    create_table :activities_interests, id: false do |t|
      t.integer :activity_id
      t.integer :interest_id

      t.timestamps
    end
  end
end
