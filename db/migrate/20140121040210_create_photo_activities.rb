class CreatePhotoActivities < ActiveRecord::Migration
  def change
    create_table :photo_activities do |t|
      t.references :Activity
      t.string :PhotoId
      t.boolean :MainPhoto

      t.timestamps
    end
  end
end
