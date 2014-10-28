class AddLastSearchCoordinatesToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_search_lat, :string
    add_column :users, :last_search_lon, :string
  end
end
