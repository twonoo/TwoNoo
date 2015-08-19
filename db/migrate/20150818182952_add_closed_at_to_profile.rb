class AddClosedAtToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :closed_at, :datetime
  end
end
