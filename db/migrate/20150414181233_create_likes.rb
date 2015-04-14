class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :user_id, null: false
      t.integer :activity_id, null: false
      t.string :referrer_uri, null: false
      t.timestamps
    end
  end
end
