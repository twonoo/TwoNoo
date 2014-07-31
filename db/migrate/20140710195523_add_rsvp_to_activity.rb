class AddRsvpToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :rsvp, :boolean, :default => '0'
  end
end
