class PromotionCodes < ActiveRecord::Migration
  def change
    create_table :promotioncodes do |t|
      t.string :code, null: false
      t.string :campaign, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
