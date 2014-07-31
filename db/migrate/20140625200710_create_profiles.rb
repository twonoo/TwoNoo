class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.datetime :birthday
      t.integer :gender
      t.integer :postcode
      t.text :about_me

      t.timestamps
    end
  end
end
