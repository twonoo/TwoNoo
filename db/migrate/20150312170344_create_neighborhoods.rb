class CreateNeighborhoods < ActiveRecord::Migration
  def change
    create_table :neighborhoods do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :state, null: false

      t.timestamps null: false
    end
  end
end
