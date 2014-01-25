class CreateJoinTableAcitivyActivityType < ActiveRecord::Migration
  def change
    create_join_table :Activities, :ActivityTypes do |t|
      # t.index [:activity_id, :activity_type_id]
      # t.index [:activity_type_id, :activity_id]
    end
  end
end
