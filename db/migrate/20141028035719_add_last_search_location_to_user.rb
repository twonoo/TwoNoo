class AddLastSearchLocationToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_search_location, :string
  end
end
