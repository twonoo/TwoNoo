class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
	t.belongs_to :user
	t.string :search

	t.timestamps
    end
  end
end
