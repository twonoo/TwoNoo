class AddCityAndStateToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :city, :string
    add_column :profiles, :state, :string
  end
end
