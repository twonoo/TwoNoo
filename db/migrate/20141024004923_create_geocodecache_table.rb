class CreateGeocodecacheTable < ActiveRecord::Migration
  def change
    create_table :geocodes do |t|
      t.string  :city
      t.string  :state
      t.float   :latitude
      t.float   :longitude
      t.string  :timezone

      t.timestamps
    end
  end
end
