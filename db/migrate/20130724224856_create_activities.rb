class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :Name
      t.datetime :StartDateTime
      t.datetime :EndDateTime
      t.string :City
      t.string :State
      t.string :StreetAddress1
      t.string :StreetAddress2
      t.string :Country
      t.string :LocationName
      t.string :Website
      t.integer :Views
      t.integer :OrganizerUserId
      t.integer :ActivityId
      t.integer :ActivityTypeId
      t.integer :ModUserId
      t.integer :CreateUserId

      t.timestamps
    end
  end
end
