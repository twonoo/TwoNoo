class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :activity_name
      t.string :location_name
      t.string :street_address_1
      t.string :street_address_2
      t.string :city
      t.string :state
      t.string :country
      t.string :website
      t.integer :activity_type_id
      t.text :description
      t.integer :views
      t.integer :user_id
      t.integer :activity_type_id

      t.timestamps
    end
  end
end
