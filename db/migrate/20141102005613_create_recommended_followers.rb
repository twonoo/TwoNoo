class CreateRecommendedFollowers < ActiveRecord::Migration
  def change
    create_table :recommended_followers do |t|
      t.belongs_to :user
      t.integer :user_id
      t.integer :recommended_follower_id
      t.integer :order
      t.datetime  :recommended_at

      t.timestamps
    end
  end
end
