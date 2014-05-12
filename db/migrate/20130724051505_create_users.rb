class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :FirstName
      t.string :LastName
      t.string :Email
      t.string :password_digest
      t.string :UserId
      t.datetime :Birthday
      t.string :Sex
      t.integer :ModUserId
      t.integer :CreateUserId

      t.timestamps
    end
  end
end
