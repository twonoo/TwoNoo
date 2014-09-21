class AddNonProfitToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :nonprofit, :integer
    add_column :profiles, :ambassador, :integer
  end
end
