class CreateProfilePhoto < ActiveRecord::Migration
  def change
    create_table :profile_photos do |t|
      t.references :Users
      t.string :PhotoId
      t.boolean :MainPhoto

      t.timestamps
    end
  end
end
