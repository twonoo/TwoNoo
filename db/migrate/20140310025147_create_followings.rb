class CreateFollowings < ActiveRecord::Migration
  def change
    drop_table :following

    create_table :followings do |t|
      t.integer :user_id1
      t.integer :user_id2 
      t.timestamps
    end
  end
end
