class CreateJoinTableUsersUsers < ActiveRecord::Migration
  def change
      create_join_table :users, :users do |t|
      # t.index [:activity_id, :activity_type_id]
      # t.index [:activity_type_id, :activity_id]
    end
  end
end
