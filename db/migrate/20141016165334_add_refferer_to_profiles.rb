class AddReffererToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :referrer, :integer, :default => '0'
  end
end
