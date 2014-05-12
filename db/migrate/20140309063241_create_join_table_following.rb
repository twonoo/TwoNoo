class CreateJoinTableFollowing < ActiveRecord::Migration
  def change
    drop_table :users_users
    
    create_table :following do |t|
      t.integer :user_id1
      t.integer :user_id2 
    end
    
  end
end
