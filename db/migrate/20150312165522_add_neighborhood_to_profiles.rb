class AddNeighborhoodToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :neighborhood, :string
  end
end
