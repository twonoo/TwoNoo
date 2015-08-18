class AddCancelledAtToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :cancelled_at, :datetime
  end
end
