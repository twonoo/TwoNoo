class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :keywords
      t.string :location
      t.integer :distance
      t.integer :user_id

      t.timestamps
    end
  end
end
