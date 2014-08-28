class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps do |t|
      t.integer :activity_id
      t.integer :user_id

      t.timestamps
    end
  end
end
