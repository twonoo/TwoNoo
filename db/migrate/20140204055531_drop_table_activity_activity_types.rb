class DropTableActivityActivityTypes < ActiveRecord::Migration
  def change
    drop_table :Activities_ActivityTypes
  end
end
