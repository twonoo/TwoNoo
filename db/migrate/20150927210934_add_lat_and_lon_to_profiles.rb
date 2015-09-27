class AddLatAndLonToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :city_state_latitude, :float
    add_column :profiles, :city_state_longitude, :float
  end
end
