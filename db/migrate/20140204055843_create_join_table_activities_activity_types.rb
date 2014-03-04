class CreateJoinTableActivitiesActivityTypes < ActiveRecord::Migration
  def change
    create_join_table :activities, :activity_types do |t|
      # t.index [:activity_id, :activity_type_id]
      # t.index [:activity_type_id, :activity_id]
    end
  end
end